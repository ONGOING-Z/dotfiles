import os
import shutil
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

from standardize_dirs import (
    create_standard_directories,
    print_summary,
    parse_args,
    main,
)


def test_dry_run_creates_nothing(tmp_path: Path):
    """测试 dry-run 模式不创建实际目录"""
    result = create_standard_directories(tmp_path, dry_run=True)
    assert set(map(Path, result["created"])) == {
        tmp_path / "project",
        tmp_path / "archive",
        tmp_path / "discard",
    }
    # ensure nothing actually created
    for p in result["created"]:
        assert not Path(p).exists()


def test_create_directories(tmp_path: Path):
    """测试正常创建目录"""
    result = create_standard_directories(tmp_path)
    for name in ("project", "archive", "discard"):
        assert (tmp_path / name).is_dir()
    assert len(result["errors"]) == 0
    assert len(result["created"]) == 3
    assert len(result["existed"]) == 0


def test_existing_directories(tmp_path: Path):
    """测试处理已存在的目录"""
    # 先创建一个目录
    (tmp_path / "project").mkdir()

    result = create_standard_directories(tmp_path)

    # project 应该在 existed 中
    assert str(tmp_path / "project") in result["existed"]
    # archive 和 discard 应该被创建
    assert len(result["created"]) == 2
    assert len(result["existed"]) == 1
    assert len(result["errors"]) == 0


def test_file_exists_with_same_name(tmp_path: Path):
    """测试当同名文件存在时的错误处理"""
    # 创建一个文件而不是目录
    (tmp_path / "project").touch()

    result = create_standard_directories(tmp_path)

    # 应该有一个错误
    assert len(result["errors"]) == 1
    assert "project 已存在但不是目录" in result["errors"][0]


def test_print_summary(capsys):
    """测试打印摘要功能"""
    results = {
        "created": ["/path/to/project", "/path/to/archive"],
        "existed": ["/path/to/discard"],
        "errors": ["测试错误"],
    }

    print_summary(results)

    captured = capsys.readouterr()
    assert "新创建: 2 个目录" in captured.out
    assert "已存在: 1 个目录" in captured.out
    assert "错误: 1 个" in captured.out
    assert "测试错误" in captured.out


def test_parse_args():
    """测试命令行参数解析"""
    # 测试默认参数
    args = parse_args([])
    assert args.path == "."
    assert args.dry_run is False

    # 测试指定路径
    args = parse_args(["/custom/path"])
    assert args.path == "/custom/path"
    assert args.dry_run is False

    # 测试 dry-run
    args = parse_args(["--dry-run"])
    assert args.path == "."
    assert args.dry_run is True

    # 测试组合
    args = parse_args(["/custom/path", "--dry-run"])
    assert args.path == "/custom/path"
    assert args.dry_run is True


def test_main_success(tmp_path: Path):
    """测试主函数成功执行"""
    test_args = [str(tmp_path)]

    with patch.object(sys, "argv", ["standardize_dirs.py"] + test_args):
        with pytest.raises(SystemExit) as exc_info:
            main()
        assert exc_info.value.code == 0

    # 验证目录被创建
    for name in ("project", "archive", "discard"):
        assert (tmp_path / name).is_dir()


def test_main_with_errors(tmp_path: Path):
    """测试主函数处理错误"""
    # 创建一个同名文件
    (tmp_path / "project").touch()

    test_args = [str(tmp_path)]

    with patch.object(sys, "argv", ["standardize_dirs.py"] + test_args):
        with pytest.raises(SystemExit) as exc_info:
            main()
        assert exc_info.value.code == 1


def test_main_dry_run(tmp_path: Path):
    """测试主函数 dry-run 模式"""
    test_args = [str(tmp_path), "--dry-run"]

    with patch.object(sys, "argv", ["standardize_dirs.py"] + test_args):
        with pytest.raises(SystemExit) as exc_info:
            main()
        assert exc_info.value.code == 0

    # 验证目录没有被创建
    for name in ("project", "archive", "discard"):
        assert not (tmp_path / name).exists()


def test_main_keyboard_interrupt(tmp_path: Path):
    """测试处理键盘中断"""
    with patch(
        "standardize_dirs.create_standard_directories", side_effect=KeyboardInterrupt
    ):
        with patch.object(sys, "argv", ["standardize_dirs.py", str(tmp_path)]):
            with pytest.raises(SystemExit) as exc_info:
                main()
            assert exc_info.value.code == 130
