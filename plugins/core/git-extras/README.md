# Git Extras 插件

增强的 Git 命令和工作流助手。

## 功能

### 别名

- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gd` - git diff
- `gco` - git checkout
- `gb` - git branch
- `glog` - 美化的提交历史
- `gundo` - 撤销上一次提交

### 函数

#### gquick [message]
快速提交所有更改
```bash
gquick "Fix typo"
```

#### gnew <branch>
创建并切换到新分支
```bash
gnew feature/awesome-feature
```

#### gdelete <branch>
删除本地和远程分支
```bash
gdelete feature/old-feature
```

#### grebase [commits]
交互式 rebase 最近的提交
```bash
grebase 5  # rebase 最近 5 个提交
```

#### gcontrib
显示贡献者统计
```bash
gcontrib
```

#### gfind <commit>
查找包含特定提交的分支
```bash
gfind abc123
```

#### gclean
清理已合并的分支
```bash
gclean
```

#### ghistory <file>
显示文件的完整历史
```bash
ghistory README.md
```

#### gstash [command]
增强的暂存操作
```bash
gstash "Work in progress"  # 暂存
gstash pop                 # 恢复
gstash list               # 列表
gstash show 0             # 查看
```

#### gflow <type> <name>
Git Flow 工作流助手
```bash
gflow feature login      # 创建 feature/login
gflow hotfix security    # 创建 hotfix/security
gflow release 1.0.0      # 创建 release/1.0.0
gflow pr                 # 获取 PR 链接
```
