# 标准化目录脚本 - 增强版

这个脚本用于创建标准化的目录结构，支持数字前缀、多种预设模板和自定义配置。

## 🎯 功能特性

- ✅ **多种预设模板**：内置多种常用目录结构模板
- ✅ **数字前缀支持**：支持使用数字前缀控制目录排序（如 `01_project`, `99_archive`）
- ✅ **自定义配置**：支持通过 JSON 配置文件自定义目录结构
- ✅ **命令行自定义**：支持通过命令行参数直接指定目录列表
- ✅ **智能异常处理**：检测目录是否已存在、权限错误等
- ✅ **详细的状态报告**：显示创建、已存在和错误信息
- ✅ **预览模式**：支持 `--dry-run` 预览将要创建的目录
- ✅ **静默模式**：支持 `--quiet` 静默输出

## 📦 安装

### 全局安装（推荐）

```bash
# 安装到 ~/.local/bin
./install.sh

# 确保 ~/.local/bin 在 PATH 中（添加到 ~/.zshrc 或 ~/.bashrc）
export PATH="$HOME/.local/bin:$PATH"
```

安装后可以直接使用 `stddirs` 命令。

### 直接使用

```bash
# 使用 Python 直接运行
python3 standardize_dirs.py

# 或赋予执行权限后直接运行
chmod +x standardize_dirs.py
./standardize_dirs.py
```

## 🚀 使用方法

### 基本用法

```bash
# 在当前目录创建默认基础结构（project, archive, discard）
stddirs

# 或使用完整路径
python3 standardize_dirs.py

# 在指定路径创建标准化目录
stddirs /path/to/your/directory
python3 standardize_dirs.py ~/Documents
```

### 使用预设模板

```bash
# 查看所有可用的预设模板
stddirs --list-presets

# 使用基础结构（带数字前缀）
stddirs --preset basic_numbered

# 使用 Java 项目结构
stddirs --preset java

# 使用 Java 完整结构
stddirs --preset java_full

# 使用学习项目结构
stddirs --preset learning

# 使用框架源码结构
stddirs --preset frameworks
```

### 自定义目录

```bash
# 通过命令行参数自定义目录列表
stddirs --dirs 01_project 02_code 03_docs 99_archive

# 或使用短选项
stddirs -d 01_project 02_code 99_archive
```

### 使用配置文件

创建配置文件 `my_config.json`：

```json
{
  "dirs": [
    "01_my_projects",
    "02_github_repo",
    "03_archive",
    "99_deprecated"
  ]
}
```

然后使用：

```bash
stddirs --config my_config.json
python3 standardize_dirs.py -c my_config.json
```

### 预览模式

```bash
# 预览将要创建的目录，不实际创建
stddirs --preset java_full --dry-run
```

### 静默模式

```bash
# 静默模式，只显示错误和摘要
stddirs --quiet
stddirs -q
```

## 📚 预设模板说明

### basic
基础结构：`project`, `archive`, `discard`

### basic_numbered
带数字前缀的基础结构：`01_project`, `02_archive`, `99_discard`

### java
Java 项目结构：`01_my_projects`, `02_github_repo`

### java_full
Java 完整结构：`01_my_projects`, `02_github_repo`, `03_archive`, `99_deprecated`

### learning
学习项目结构：`01_learning`, `02_applications`, `03_demos`, `04_sdk`, `99_archive`

### frameworks
框架源码结构：`01_spring`, `02_database`, `03_mq`, `99_others`

## 💡 数字前缀使用建议

- **01-09**：主要目录（最常用）
- **10-89**：次要目录（按重要性排序）
- **90-99**：归档/废弃目录（放在最后）
  - `99_archive`：归档目录
  - `99_deprecated`：已弃用目录
  - `99_discard`：待删除目录

## 📝 目录说明

- **project/01_project**：用于存放正在进行的项目文件
- **archive/02_archive/03_archive**：用于存放已完成的归档文件
- **discard/99_discard**：用于存放待删除或废弃的文件
- **deprecated/99_deprecated**：用于存放已弃用但保留参考的文件

## 🛠️ 异常处理

脚本会处理以下异常情况：

1. **目录已存在**：如果目录已存在，会显示"已存在"状态，不会报错
2. **同名文件存在**：如果存在同名文件但不是目录，会报错
3. **权限不足**：如果权限不足，会显示权限错误
4. **其他错误**：捕获并显示其他可能的错误

## 📊 退出码

- `0`：成功完成
- `1`：发生错误
- `130`：用户中断（Ctrl+C）

## 🔧 命令行参数

```
positional arguments:
  path                  目标路径，默认当前目录

optional arguments:
  -h, --help           显示帮助信息
  --preset, -p         使用预设模板（basic, basic_numbered, java, java_full, learning, frameworks）
  --config, -c FILE    从 JSON 配置文件加载目录列表
  --dirs, -d DIR [DIR ...]  自定义目录列表（可指定多个）
  --dry-run            仅预览将要创建的目录，不实际创建
  --list-presets       列出所有可用的预设模板
  --quiet, -q          静默模式，只显示错误和摘要
```

## 📋 配置文件格式

JSON 配置文件格式：

```json
{
  "dirs": [
    "01_project",
    "02_code",
    "03_docs",
    "99_archive"
  ]
}
```

## 🎨 完整示例

```bash
# 示例 1: 在当前目录创建 Java 项目结构
stddirs --preset java_full

# 示例 2: 在指定目录创建自定义结构
stddirs --dirs 01_learning 02_projects 99_archive ~/Documents

# 示例 3: 使用配置文件创建目录
stddirs --config my_config.json /path/to/project

# 示例 4: 预览模式，查看将要创建的目录
stddirs --preset learning --dry-run

# 示例 5: 查看所有预设模板
stddirs --list-presets
```

## 🧪 测试

### 使用虚拟环境运行测试

```bash
# 使用测试脚本（推荐）
./run_tests.sh

# 或手动设置虚拟环境
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate     # Windows

# 安装测试依赖
pip install -r requirements.txt

# 运行测试
pytest test_standardize_dirs.py -v
```

### 测试覆盖

测试覆盖了以下功能：
- ✅ 基本目录创建
- ✅ 数字前缀目录创建
- ✅ 预设模板功能
- ✅ 配置文件加载
- ✅ 自定义目录列表
- ✅ 异常处理（已存在目录、同名文件、权限错误）
- ✅ Dry-run 模式
- ✅ 静默模式
- ✅ 命令行参数解析

## 📌 系统要求

- Python 3.6+
- 标准库（无需额外依赖）
- pytest（仅测试需要）

## 🔄 与旧版本的区别

- ✅ 新增预设模板支持
- ✅ 新增数字前缀支持
- ✅ 新增配置文件支持
- ✅ 新增预览模式（dry-run）
- ✅ 新增静默模式
- ✅ 统一了 `stddirs` 和 `standardize_dirs.py` 的功能

## 📞 帮助

```bash
# 查看完整帮助信息
stddirs --help
python3 standardize_dirs.py --help
```
