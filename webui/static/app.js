// Vue 3 应用
const { createApp } = Vue;

createApp({
    data() {
        return {
            currentView: 'dashboard',
            config: {
                preferences: {
                    shell: 'zsh',
                    theme: 'dracula',
                    plugins: []
                },
                components: {}
            },
            stats: {},
            files: [],
            themes: [],
            snapshots: [],
            history: [],
            diff: null,
            taskLog: '',
            gitStatus: null,
            commitMessage: '',
            graphFilter: '',
            originalGraphData: null,
            selectedFile: null,
            fileContent: '',
            editMode: false,
            fileFilter: '',
            newSnapshotName: '',
            healthStatus: null,
            notification: null,
            dependencyGraph: null
        };
    },

    computed: {
        filteredFiles() {
            if (!this.fileFilter) return this.files;
            const filter = this.fileFilter.toLowerCase();
            return this.files.filter(f =>
                f.name.toLowerCase().includes(filter) ||
                f.path.toLowerCase().includes(filter)
            );
        },
        hasDiff() {
            if (!this.diff) return false;
            return (this.diff.missing_source.length + this.diff.missing_target.length + this.diff.not_symlink.length + this.diff.wrong_link.length + this.diff.content_diff.length) > 0;
        }
    },

    methods: {
        async refreshData() {
            this.showNotification('正在刷新数据...', 'info');
            await Promise.all([
                this.loadConfiguration(),
                this.loadStats(),
                this.loadFiles(),
                this.loadThemes(),
                this.loadSnapshots(),
                this.loadHistory()
            ]);
            this.showNotification('数据刷新成功', 'success');
        },

        async loadConfiguration() {
            try {
                const response = await axios.get('/api/config');
                this.config = response.data;
            } catch (error) {
                console.error('加载配置失败:', error);
                this.showNotification('加载配置失败', 'error');
            }
        },

        async saveConfiguration() {
            try {
                await axios.post('/api/config', this.config);
                this.showNotification('配置保存成功', 'success');
            } catch (error) {
                console.error('保存配置失败:', error);
                this.showNotification('保存配置失败', 'error');
            }
        },

        async loadStats() {
            try {
                const response = await axios.get('/api/stats');
                this.stats = response.data;
            } catch (error) {
                console.error('加载统计信息失败:', error);
            }
        },

        async loadFiles() {
            try {
                const response = await axios.get('/api/files');
                this.files = response.data;
            } catch (error) {
                console.error('加载文件列表失败:', error);
            }
        },

        async loadThemes() {
            try {
                const response = await axios.get('/api/themes');
                this.themes = response.data;
            } catch (error) {
                console.error('加载主题列表失败:', error);
            }
        },

        async loadSnapshots() {
            try {
                const response = await axios.get('/api/snapshots');
                this.snapshots = response.data;
            } catch (error) {
                console.error('加载快照列表失败:', error);
            }
        },

        async loadHistory() {
            try {
                const response = await axios.get('/api/history');
                this.history = response.data;
            } catch (error) {
                console.error('加载历史记录失败:', error);
            }
        },

        async loadDependencies() {
            try {
                const response = await axios.get('/api/dependencies');
                return response.data;
            } catch (error) {
                console.error('加载依赖关系失败:', error);
                return { nodes: [], edges: [] };
            }
        },

        async openDiffView() {
            this.currentView = 'diff';
            await this.loadDiff();
        },

        async loadDiff() {
            try {
                const response = await axios.get('/api/diff', { params: { detail_hash: 0 } });
                this.diff = response.data;
                this.showNotification('差异已更新', 'success');
            } catch (error) {
                console.error('加载差异失败:', error);
                this.showNotification('加载差异失败', 'error');
            }
        },

        async syncAll(allowOverwrite) {
            if (!this.hasDiff) {
                this.showNotification('没有差异需要同步', 'info');
                return;
            }
            try {
                const response = await axios.post('/api/sync', { allow_overwrite: !!allowOverwrite });
                const ok = response.data && response.data.actions && response.data.actions.filter(a => a.status === 'ok').length || 0;
                const err = response.data && response.data.actions && response.data.actions.filter(a => a.status === 'error').length || 0;
                this.showNotification(`同步完成：成功 ${ok}，失败 ${err}`, err ? 'error' : 'success');
                await this.loadDiff();
                await this.loadFiles();
                await this.loadStats();
            } catch (error) {
                console.error('同步失败:', error);
                this.showNotification('同步失败', 'error');
            }
        },

        async refreshDependencies() {
            const data = await this.loadDependencies();
            this.renderDependencyGraph(data);
            this.showNotification('依赖关系图已刷新', 'success');
        },

        renderDependencyGraph(data) {
            const container = document.getElementById('dependency-graph');
            if (!container) return;

            // 保存原始数据
            this.originalGraphData = data;

            // 转换数据格式为 vis.js 需要的格式
            const nodes = new vis.DataSet(
                data.nodes.map(node => ({
                    id: node.id,
                    label: node.label,
                    color: node.type === 'source' ? '#6366f1' : '#10b981',
                    title: node.path,
                    shape: 'box',
                    font: { color: '#f1f5f9' },
                    broken: false // 标记是否为断链
                }))
            );

            const edges = new vis.DataSet(
                data.edges.map(edge => ({
                    from: edge.from,
                    to: edge.to,
                    arrows: 'to',
                    label: edge.label,
                    font: { color: '#cbd5e1', size: 10 }
                }))
            );

            const graphData = { nodes, edges };

            const options = {
                layout: {
                    hierarchical: {
                        direction: 'LR',
                        sortMethod: 'directed',
                        levelSeparation: 200,
                        nodeSpacing: 150
                    }
                },
                physics: {
                    enabled: false
                },
                nodes: {
                    borderWidth: 2,
                    borderWidthSelected: 3,
                    color: {
                        border: '#475569',
                        background: '#1e293b',
                        highlight: {
                            border: '#6366f1',
                            background: '#334155'
                        }
                    }
                },
                edges: {
                    color: { color: '#475569' },
                    smooth: {
                        type: 'cubicBezier',
                        forceDirection: 'horizontal'
                    }
                },
                interaction: {
                    hover: true,
                    tooltipDelay: 100
                }
            };

            if (this.dependencyGraph) {
                this.dependencyGraph.destroy();
            }

            this.dependencyGraph = new vis.Network(container, graphData, options);

            // 添加节点点击事件
            this.dependencyGraph.on("click", (params) => {
                if (params.nodes.length > 0) {
                    const nodeId = params.nodes[0];
                    this.handleNodeClick(nodeId);
                }
            });

            // 初始视图优化：先适配再放大，保证默认清晰
            try {
                this.dependencyGraph.fit({ animation: false, padding: 120 });
                this.dependencyGraph.moveTo({ scale: 1.4 });
            } catch (e) {
                // 忽略初始化阶段可能的尺寸计算异常
            }
        },

        async highlightBrokenLinks() {
            if (!this.diff) {
                await this.loadDiff();
            }
            
            if (!this.diff || !this.dependencyGraph) return;

            const brokenNodes = new Set();
            
            // 收集断链节点
            this.diff.missing_source.forEach(item => {
                const sourceName = item.source.split('/').pop();
                brokenNodes.add(sourceName);
            });
            
            this.diff.missing_target.forEach(item => {
                const targetName = item.target.split('/').pop();
                brokenNodes.add(targetName);
            });
            
            this.diff.wrong_link.forEach(item => {
                const targetName = item.target.split('/').pop();
                brokenNodes.add(targetName);
            });

            // 更新节点颜色
            const nodes = this.dependencyGraph.body.data.nodes;
            const updates = nodes.get().map(node => {
                if (brokenNodes.has(node.id)) {
                    return { id: node.id, color: '#ef4444', broken: true };
                }
                return { id: node.id, color: node.type === 'source' ? '#6366f1' : '#10b981', broken: false };
            });
            
            nodes.update(updates);
            this.showNotification('断链已高亮显示', 'success');
        },

        resetGraphView() {
            if (!this.dependencyGraph || !this.originalGraphData) return;
            
            // 重置节点颜色
            const nodes = this.dependencyGraph.body.data.nodes;
            const updates = nodes.get().map(node => ({
                id: node.id,
                color: node.type === 'source' ? '#6366f1' : '#10b981',
                broken: false
            }));
            
            nodes.update(updates);
            
            // 重置视图
            this.dependencyGraph.fit({ animation: true, padding: 120 });
            this.dependencyGraph.moveTo({ scale: 1.4 });
            this.showNotification('视图已重置', 'success');
        },

        applyGraphFilter() {
            if (!this.dependencyGraph || !this.originalGraphData) return;
            
            const nodes = this.dependencyGraph.body.data.nodes;
            const edges = this.dependencyGraph.body.data.edges;
            
            let filteredNodes = nodes.get();
            let filteredEdges = edges.get();
            
            if (this.graphFilter === 'broken') {
                // 仅显示断链
                const brokenNodeIds = filteredNodes.filter(node => node.broken).map(node => node.id);
                filteredNodes = filteredNodes.filter(node => node.broken);
                filteredEdges = filteredEdges.filter(edge => 
                    brokenNodeIds.includes(edge.from) || brokenNodeIds.includes(edge.to)
                );
            } else if (this.graphFilter === 'source') {
                // 仅显示源文件
                filteredNodes = filteredNodes.filter(node => node.type === 'source');
                filteredEdges = filteredEdges.filter(edge => 
                    filteredNodes.some(node => node.id === edge.from)
                );
            } else if (this.graphFilter === 'target') {
                // 仅显示目标文件
                filteredNodes = filteredNodes.filter(node => node.type === 'target');
                filteredEdges = filteredEdges.filter(edge => 
                    filteredNodes.some(node => node.id === edge.to)
                );
            }
            
            // 更新图表
            nodes.clear();
            edges.clear();
            nodes.add(filteredNodes);
            edges.add(filteredEdges);
            
            this.dependencyGraph.fit({ animation: true, padding: 120 });
        },

        handleNodeClick(nodeId) {
            // 处理节点点击事件
            const node = this.dependencyGraph.body.data.nodes.get(nodeId);
            if (node) {
                this.showNotification(`点击了节点: ${node.label}`, 'info');
                // 可以在这里添加更多交互，比如打开文件预览
            }
        },

        async selectFile(file) {
            this.selectedFile = file;
            this.currentView = 'preview';
            this.editMode = false;

            try {
                const response = await axios.get(`/api/files/${file.path}`);
                this.fileContent = response.data.content;
            } catch (error) {
                console.error('加载文件内容失败:', error);
                this.showNotification('加载文件内容失败', 'error');
            }
        },

        async saveFileContent() {
            if (!this.selectedFile) return;

            try {
                await axios.put(`/api/files/${this.selectedFile.path}`, {
                    content: this.fileContent
                });
                this.showNotification('文件保存成功', 'success');
                this.editMode = false;
            } catch (error) {
                console.error('保存文件失败:', error);
                this.showNotification('保存文件失败', 'error');
            }
        },

        async createSnapshot() {
            const name = this.newSnapshotName || 'snapshot';

            try {
                await axios.post('/api/snapshots', { name });
                this.showNotification('快照创建成功', 'success');
                this.newSnapshotName = '';
                await this.loadSnapshots();
            } catch (error) {
                console.error('创建快照失败:', error);
                this.showNotification('创建快照失败', 'error');
            }
        },

        async runHealthCheck() {
            this.healthStatus = { status: 'checking', output: '正在检查...' };

            try {
                const response = await axios.get('/api/health');
                this.healthStatus = response.data;
                this.showNotification('健康检查完成', 'success');
            } catch (error) {
                console.error('健康检查失败:', error);
                this.healthStatus = {
                    status: 'error',
                    output: '检查失败: ' + error.message
                };
                this.showNotification('健康检查失败', 'error');
            }
        },

        formatSize(bytes) {
            if (!bytes) return '0 B';
            const sizes = ['B', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(1024));
            return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
        },

        formatDate(dateStr) {
            if (!dateStr) return '-';
            const date = new Date(dateStr);
            return date.toLocaleString('zh-CN', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            });
        },

        getFileIcon(filename) {
            const ext = filename.split('.').pop().toLowerCase();
            const iconMap = {
                'sh': 'fas fa-terminal',
                'bash': 'fas fa-terminal',
                'zsh': 'fas fa-terminal',
                'conf': 'fas fa-cog',
                'config': 'fas fa-cog',
                'yaml': 'fas fa-file-code',
                'yml': 'fas fa-file-code',
                'json': 'fas fa-file-code',
                'vim': 'fas fa-file-alt',
                'tmux': 'fas fa-file-alt',
                'git': 'fab fa-git-alt',
                'md': 'fas fa-file-alt'
            };
            return iconMap[ext] || 'fas fa-file';
        },

        showNotification(message, type = 'info') {
            this.notification = { message, type };
            setTimeout(() => {
                this.notification = null;
            }, 3000);
        },

        async runTask(taskName) {
            try {
                const response = await axios.post('/api/tasks/run', { task: taskName });
                this.taskLog = `返回码: ${response.data.returncode}\n\n标准输出:\n${response.data.stdout}\n\n标准错误:\n${response.data.stderr}`;
                this.showNotification('任务执行完成', response.data.status === 'ok' ? 'success' : 'error');
            } catch (error) {
                console.error('任务执行失败:', error);
                this.showNotification('任务执行失败', 'error');
            }
        },

        async loadGitStatus() {
            try {
                const response = await axios.get('/api/git/status');
                this.gitStatus = response.data;
            } catch (error) {
                console.error('加载Git状态失败:', error);
                this.showNotification('加载Git状态失败', 'error');
            }
        },

        async stageFile(file) {
            try {
                await axios.post('/api/git/commit', { message: 'Stage file', files: [file] });
                this.showNotification('文件已暂存', 'success');
                await this.loadGitStatus();
            } catch (error) {
                console.error('暂存文件失败:', error);
                this.showNotification('暂存文件失败', 'error');
            }
        },

        async unstageFile(file) {
            try {
                await axios.post('/api/git/reset', { files: [file] });
                this.showNotification('文件已取消暂存', 'success');
                await this.loadGitStatus();
            } catch (error) {
                console.error('取消暂存失败:', error);
                this.showNotification('取消暂存失败', 'error');
            }
        },

        async resetFile(file) {
            try {
                await axios.post('/api/git/reset', { files: [file] });
                this.showNotification('文件已回滚', 'success');
                await this.loadGitStatus();
            } catch (error) {
                console.error('回滚文件失败:', error);
                this.showNotification('回滚文件失败', 'error');
            }
        },

        async commitChanges() {
            if (!this.commitMessage.trim()) {
                this.showNotification('请输入提交信息', 'error');
                return;
            }
            try {
                const response = await axios.post('/api/git/commit', { 
                    message: this.commitMessage, 
                    files: this.gitStatus.staged 
                });
                if (response.data.success) {
                    this.showNotification('提交成功', 'success');
                    this.commitMessage = '';
                    await this.loadGitStatus();
                } else {
                    this.showNotification('提交失败', 'error');
                }
            } catch (error) {
                console.error('提交失败:', error);
                this.showNotification('提交失败', 'error');
            }
        }
    },

    async mounted() {
        await this.refreshData();

        // 如果在依赖关系视图，渲染图表
        this.$watch('currentView', async (newView) => {
            if (newView === 'dependencies') {
                await this.$nextTick();
                const data = await this.loadDependencies();
                this.renderDependencyGraph(data);
            }
        });
    },

    methods: {
        // 保留原有 methods 内容（此处是补充 runTask 方法），文件中已有 methods，不重复定义
    }
    }
}).mount('#app');
