#!/usr/bin/env python3
"""
标准化目录脚本
创建 project, archive, discard 三个标准目录
包含异常处理逻辑
"""

import os
import sys
import argparse
from pathlib import Path


def create_standard_directories(base_path: str = ".", dry_run: bool = False):
    """
    创建标准化目录
    
    Args:
        base_path (str): 基础路径，默认为当前目录
    
    Returns:
        dict: 创建结果信息
    """
    # 定义标准目录名称
    standard_dirs = ["project", "archive", "discard"]
    
    # 转换为Path对象
    base_path = Path(base_path).resolve()
    
    results = {
        "created": [],
        "existed": [],
        "errors": []
    }
    
    print(f"正在标准化目录: {base_path}")
    print("-" * 50)
    
    for dir_name in standard_dirs:
        dir_path = base_path / dir_name
        
        try:
            if dir_path.exists():
                if dir_path.is_dir():
                    print(f"✓ 目录已存在: {dir_name}")
                    results["existed"].append(str(dir_path))
                else:
                    print(f"✗ 错误: {dir_name} 已存在但不是目录")
                    results["errors"].append(f"{dir_name} 已存在但不是目录")
            else:
                # 创建目录或进行 dry-run
                if dry_run:
                    print(f"↷ 预创建: {dir_name}")
                    results["created"].append(str(dir_path))
                else:
                    dir_path.mkdir(parents=True, exist_ok=True)
                    print(f"✓ 创建目录: {dir_name}")
                    results["created"].append(str(dir_path))
                
        except PermissionError:
            error_msg = f"权限不足，无法创建目录 {dir_name}"
            print(f"✗ {error_msg}")
            results["errors"].append(error_msg)
        except Exception as e:
            error_msg = f"创建目录 {dir_name} 时发生错误: {str(e)}"
            print(f"✗ {error_msg}")
            results["errors"].append(error_msg)
    
    return results


def print_summary(results):
    """打印创建结果摘要"""
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


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="创建标准化目录: project, archive, discard")
    parser.add_argument("path", nargs="?", default=".", help="目标路径，默认当前目录")
    parser.add_argument("--dry-run", action="store_true", help="仅打印将要创建的目录，不实际创建")
    return parser.parse_args(argv)


def main():
    """主函数"""
    args = parse_args(sys.argv[1:])
    target_path = args.path
    
    try:
        # 创建标准化目录
        results = create_standard_directories(target_path, dry_run=args.dry_run)
        
        # 打印摘要
        print_summary(results)
        
        # 返回适当的退出码
        if results["errors"]:
            print(f"\n⚠️  有 {len(results['errors'])} 个错误，请检查上述信息")
            sys.exit(1)
        else:
            if args.dry_run:
                print(f"\n✅ 预检完成（未实际创建目录）！")
            else:
                print(f"\n✅ 目录标准化完成！")
            sys.exit(0)
            
    except KeyboardInterrupt:
        print("\n\n操作被用户中断")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ 程序执行出错: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
