#!/usr/bin/env python3
"""
标准化目录脚本 - 增强版
支持数字前缀、配置化目录结构、多种预设模式
"""

import os
import sys
import argparse
import json
from pathlib import Path
from typing import List, Dict, Optional


# 预设目录结构模板
PRESET_TEMPLATES = {
    "basic": {
        "name": "基础结构",
        "description": "简单的三个目录：project, archive, discard",
        "dirs": ["project", "archive", "discard"],
    },
    "basic_numbered": {
        "name": "基础结构（带数字前缀）",
        "description": "带数字前缀的基础结构：01_project, 02_archive, 99_discard",
        "dirs": ["01_project", "02_archive", "99_discard"],
    },
    "java": {
        "name": "Java 项目结构",
        "description": "Java 学习项目结构：01_my_projects, 02_github_repo",
        "dirs": [
            "01_my_projects",
            "02_github_repo",
        ],
    },
    "java_full": {
        "name": "Java 完整结构",
        "description": "完整的 Java 项目结构（包含子目录）",
        "dirs": [
            "01_my_projects",
            "02_github_repo",
            "03_archive",
            "99_deprecated",
        ],
    },
    "learning": {
        "name": "学习项目结构",
        "description": "学习项目结构：01_learning, 02_applications, 03_demos, 99_archive",
        "dirs": [
            "01_learning",
            "02_applications",
            "03_demos",
            "04_sdk",
            "99_archive",
        ],
    },
    "frameworks": {
        "name": "框架源码结构",
        "description": "框架源码学习结构：01_spring, 02_database, 03_mq, 99_others",
        "dirs": [
            "01_spring",
            "02_database",
            "03_mq",
            "99_others",
        ],
    },
}


def load_custom_config(config_path: str) -> Optional[Dict]:
    """从 JSON 文件加载自定义配置"""
    config_file = Path(config_path)
    if not config_file.exists():
        return None

    try:
        with open(config_file, "r", encoding="utf-8") as f:
            config = json.load(f)
            return config
    except (json.JSONDecodeError, IOError) as e:
        print(f"⚠️  警告: 无法加载配置文件 {config_path}: {e}")
        return None


def get_directory_list(
    preset: Optional[str] = None,
    custom_config: Optional[str] = None,
    custom_dirs: Optional[List[str]] = None,
) -> List[str]:
    """
    获取要创建的目录列表

    Args:
        preset: 预设模板名称
        custom_config: 自定义配置文件路径
        custom_dirs: 自定义目录列表（命令行参数）

    Returns:
        目录名称列表
    """
    # 优先级：自定义目录 > 自定义配置 > 预设模板 > 默认
    if custom_dirs:
        return custom_dirs

    if custom_config:
        config = load_custom_config(custom_config)
        if config and "dirs" in config:
            return config["dirs"]

    if preset and preset in PRESET_TEMPLATES:
        return PRESET_TEMPLATES[preset]["dirs"]

    # 默认使用基础结构
    return PRESET_TEMPLATES["basic"]["dirs"]


def create_standard_directories(
    base_path: str = ".",
    dirs: List[str] = None,
    dry_run: bool = False,
    verbose: bool = True,
) -> Dict:
    """
    创建标准化目录

    Args:
        base_path: 基础路径，默认为当前目录
        dirs: 要创建的目录列表
        dry_run: 是否仅预览不实际创建
        verbose: 是否显示详细信息

    Returns:
        创建结果信息字典
    """
    if dirs is None:
        dirs = PRESET_TEMPLATES["basic"]["dirs"]

    # 转换为Path对象
    base_path = Path(base_path).resolve()

    results = {"created": [], "existed": [], "errors": []}

    if verbose:
        print(f"正在标准化目录: {base_path}")
        print("-" * 50)

    for dir_name in dirs:
        dir_path = base_path / dir_name

        try:
            if dir_path.exists():
                if dir_path.is_dir():
                    if verbose:
                        print(f"✓ 目录已存在: {dir_name}")
                    results["existed"].append(str(dir_path))
                else:
                    error_msg = f"{dir_name} 已存在但不是目录"
                    if verbose:
                        print(f"✗ 错误: {error_msg}")
                    results["errors"].append(error_msg)
            else:
                # 创建目录或进行 dry-run
                if dry_run:
                    if verbose:
                        print(f"↷ 预创建: {dir_name}")
                    results["created"].append(str(dir_path))
                else:
                    dir_path.mkdir(parents=True, exist_ok=True)
                    if verbose:
                        print(f"✓ 创建目录: {dir_name}")
                    results["created"].append(str(dir_path))

        except PermissionError:
            error_msg = f"权限不足，无法创建目录 {dir_name}"
            if verbose:
                print(f"✗ {error_msg}")
            results["errors"].append(error_msg)
        except Exception as e:
            error_msg = f"创建目录 {dir_name} 时发生错误: {str(e)}"
            if verbose:
                print(f"✗ {error_msg}")
            results["errors"].append(error_msg)

    return results


def print_summary(results: Dict, verbose: bool = True):
    """打印创建结果摘要"""
    if not verbose:
        return

    print("\n" + "=" * 50)
    print("创建结果摘要:")
    print(f"✓ 新创建: {len(results['created'])} 个目录")
    print(f"✓ 已存在: {len(results['existed'])} 个目录")
    print(f"✗ 错误: {len(results['errors'])} 个")

    if results["created"]:
        print("\n新创建的目录:")
        for dir_path in results["created"]:
            print(f"  - {dir_path}")

    if results["existed"]:
        print("\n已存在的目录:")
        for dir_path in results["existed"]:
            print(f"  - {dir_path}")

    if results["errors"]:
        print("\n错误信息:")
        for error in results["errors"]:
            print(f"  - {error}")


def list_presets():
    """列出所有可用的预设模板"""
    print("\n可用的预设模板:")
    print("=" * 50)
    for key, template in PRESET_TEMPLATES.items():
        print(f"\n{key}:")
        print(f"  名称: {template['name']}")
        print(f"  说明: {template['description']}")
        print(f"  目录: {', '.join(template['dirs'])}")


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="创建标准化目录结构（支持数字前缀、预设模板、自定义配置）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s                              # 使用默认基础结构
  %(prog)s --preset java                # 使用 Java 项目预设
  %(prog)s --preset basic_numbered      # 使用带数字前缀的基础结构
  %(prog)s --dirs 01_project 02_code 99_archive  # 自定义目录
  %(prog)s --config my_config.json      # 使用自定义配置文件
  %(prog)s --list-presets               # 列出所有预设模板
  %(prog)s --dry-run                    # 预览模式，不实际创建
        """,
    )

    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="目标路径，默认当前目录",
    )

    parser.add_argument(
        "--preset",
        "-p",
        choices=list(PRESET_TEMPLATES.keys()),
        help="使用预设模板（可用: %(choices)s）",
    )

    parser.add_argument(
        "--config",
        "-c",
        metavar="FILE",
        help="从 JSON 配置文件加载目录列表（格式: {\"dirs\": [\"dir1\", \"dir2\"]}）",
    )

    parser.add_argument(
        "--dirs",
        "-d",
        nargs="+",
        metavar="DIR",
        help="自定义目录列表（可指定多个）",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="仅预览将要创建的目录，不实际创建",
    )

    parser.add_argument(
        "--list-presets",
        action="store_true",
        help="列出所有可用的预设模板",
    )

    parser.add_argument(
        "--quiet",
        "-q",
        action="store_true",
        help="静默模式，只显示错误和摘要",
    )

    return parser.parse_args(argv)


def main():
    """主函数"""
    args = parse_args(sys.argv[1:])

    # 如果请求列出预设，则列出后退出
    if args.list_presets:
        list_presets()
        sys.exit(0)

    target_path = args.path
    verbose = not args.quiet

    try:
        # 获取要创建的目录列表
        dirs = get_directory_list(
            preset=args.preset,
            custom_config=args.config,
            custom_dirs=args.dirs,
        )

        if not dirs:
            print("❌ 错误: 没有指定要创建的目录")
            sys.exit(1)

        # 创建标准化目录
        results = create_standard_directories(
            target_path, dirs=dirs, dry_run=args.dry_run, verbose=verbose
        )

        # 打印摘要
        print_summary(results, verbose=verbose)

        # 返回适当的退出码
        if results["errors"]:
            if verbose:
                print(f"\n⚠️  有 {len(results['errors'])} 个错误，请检查上述信息")
            sys.exit(1)
        else:
            if args.dry_run:
                if verbose:
                    print(f"\n✅ 预检完成（未实际创建目录）！")
            else:
                if verbose:
                    print(f"\n✅ 目录标准化完成！")
            sys.exit(0)

    except KeyboardInterrupt:
        print("\n\n操作被用户中断")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ 程序执行出错: {str(e)}")
        import traceback

        if args.verbose if hasattr(args, "verbose") else False:
            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
