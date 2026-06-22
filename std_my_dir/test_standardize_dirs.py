import os
import json
import shutil
import sys
from pathlib import Path
from unittest.mock import patch
import pytest

from standardize_dirs import (
    create_standard_directories,
    print_summary,
    parse_args,
    main,
    get_directory_list,
    load_custom_config,
    list_presets,
    PRESET_TEMPLATES,
)


def test_dry_run_creates_nothing(tmp_path: Path):
    """测试 dry-run 模式不创建实际目录"""
    dirs = ["project", "archive", "discard"]
    result = create_standard_directories(tmp_path, dirs=dirs, dry_run=True)
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
    dirs = ["project", "archive", "discard"]
    result = create_standard_directories(tmp_path, dirs=dirs)
    for name in ("project", "archive", "discard"):
        assert (tmp_path / name).is_dir()
    assert len(result["errors"]) == 0
    assert len(result["created"]) == 3
    assert len(result["existed"]) == 0


def test_existing_directories(tmp_path: Path):
    """测试处理已存在的目录"""
    # 先创建一个目录
    (tmp_path / "project").mkdir()
    dirs = ["project", "archive", "discard"]

    result = create_standard_directories(tmp_path, dirs=dirs)

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
    dirs = ["project", "archive", "discard"]

    result = create_standard_directories(tmp_path, dirs=dirs)

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
    assert args.preset is None
    assert args.config is None
    assert args.dirs is None

    # 测试指定路径
    args = parse_args(["/custom/path"])
    assert args.path == "/custom/path"
    assert args.dry_run is False

    # 测试 dry-run
    args = parse_args(["--dry-run"])
    assert args.path == "."
    assert args.dry_run is True

    # 测试预设模板
    args = parse_args(["--preset", "basic"])
    assert args.preset == "basic"

    # 测试自定义目录
    args = parse_args(["--dirs", "01_project", "02_code"])
    assert args.dirs == ["01_project", "02_code"]

    # 测试配置文件
    args = parse_args(["--config", "config.json"])
    assert args.config == "config.json"

    # 测试组合
    args = parse_args(["/custom/path", "--dry-run", "--preset", "java"])
    assert args.path == "/custom/path"
    assert args.dry_run is True
    assert args.preset == "java"


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


def test_get_directory_list():
    """测试获取目录列表函数"""
    # 测试默认（无参数）
    dirs = get_directory_list()
    assert len(dirs) == 3
    assert "project" in dirs

    # 测试预设模板
    dirs = get_directory_list(preset="basic_numbered")
    assert "01_project" in dirs
    assert "99_discard" in dirs

    # 测试自定义目录
    custom_dirs = ["01_project", "02_code", "99_archive"]
    dirs = get_directory_list(custom_dirs=custom_dirs)
    assert dirs == custom_dirs

    # 测试 Java 预设
    dirs = get_directory_list(preset="java")
    assert "01_my_projects" in dirs
    assert "02_github_repo" in dirs


def test_load_custom_config(tmp_path: Path):
    """测试加载自定义配置文件"""
    # 创建测试配置文件
    config_file = tmp_path / "test_config.json"
    config_data = {"dirs": ["01_project", "02_code", "99_archive"]}
    with open(config_file, "w") as f:
        json.dump(config_data, f)

    # 测试加载配置
    config = load_custom_config(str(config_file))
    assert config is not None
    assert config["dirs"] == config_data["dirs"]

    # 测试不存在的文件
    config = load_custom_config(str(tmp_path / "nonexistent.json"))
    assert config is None

    # 测试无效 JSON
    invalid_config = tmp_path / "invalid.json"
    invalid_config.write_text("{ invalid json")
    config = load_custom_config(str(invalid_config))
    assert config is None


def test_preset_templates():
    """测试预设模板是否都存在"""
    assert "basic" in PRESET_TEMPLATES
    assert "basic_numbered" in PRESET_TEMPLATES
    assert "java" in PRESET_TEMPLATES
    assert "java_full" in PRESET_TEMPLATES
    assert "learning" in PRESET_TEMPLATES
    assert "frameworks" in PRESET_TEMPLATES

    # 测试每个模板都有必要的字段
    for key, template in PRESET_TEMPLATES.items():
        assert "name" in template
        assert "description" in template
        assert "dirs" in template
        assert isinstance(template["dirs"], list)
        assert len(template["dirs"]) > 0


def test_create_with_numbered_dirs(tmp_path: Path):
    """测试创建带数字前缀的目录"""
    dirs = ["01_project", "02_code", "99_archive"]
    result = create_standard_directories(tmp_path, dirs=dirs)

    assert len(result["created"]) == 3
    assert len(result["errors"]) == 0
    for dir_name in dirs:
        assert (tmp_path / dir_name).is_dir()


def test_create_with_preset(tmp_path: Path):
    """测试使用预设模板创建目录"""
    dirs = get_directory_list(preset="java_full")
    result = create_standard_directories(tmp_path, dirs=dirs)

    assert len(result["created"]) == len(dirs)
    for dir_name in dirs:
        assert (tmp_path / dir_name).is_dir()


def test_quiet_mode(tmp_path: Path):
    """测试静默模式"""
    dirs = ["project", "archive", "discard"]
    result = create_standard_directories(tmp_path, dirs=dirs, verbose=False)

    # 静默模式下应该仍然创建目录
    assert len(result["created"]) == 3
    for dir_name in dirs:
        assert (tmp_path / dir_name).is_dir()


def test_list_presets(capsys):
    """测试列出预设模板功能"""
    list_presets()
    captured = capsys.readouterr()

    # 检查是否输出了预设模板信息
    assert "可用的预设模板" in captured.out
    for key in PRESET_TEMPLATES.keys():
        assert key in captured.out


def test_get_directory_list_from_custom_config(tmp_path: Path):
    """自定义 JSON 含 dirs 时应使用该列表"""
    cfg = tmp_path / "dirs.json"
    cfg.write_text(json.dumps({"dirs": ["a", "b"]}), encoding="utf-8")
    assert get_directory_list(custom_config=str(cfg)) == ["a", "b"]


def test_get_directory_list_custom_config_no_dirs_key(tmp_path: Path):
    """自定义 JSON 无 dirs 时应回退到默认基础结构"""
    cfg = tmp_path / "empty.json"
    cfg.write_text(json.dumps({"note": "x"}), encoding="utf-8")
    assert get_directory_list(custom_config=str(cfg)) == PRESET_TEMPLATES["basic"]["dirs"]


def test_get_directory_list_learning_and_frameworks_presets():
    assert "01_learning" in get_directory_list(preset="learning")
    assert "01_spring" in get_directory_list(preset="frameworks")


def test_print_summary_not_verbose(capsys):
    print_summary({"created": [], "existed": [], "errors": []}, verbose=False)
    assert capsys.readouterr().out == ""


def test_create_standard_directories_permission_error(tmp_path: Path):
    with patch.object(Path, "mkdir", side_effect=PermissionError("denied")):
        result = create_standard_directories(tmp_path, dirs=["x"])
    assert len(result["errors"]) == 1
    assert "权限不足" in result["errors"][0]


def test_create_standard_directories_unexpected_error(tmp_path: Path):
    with patch.object(Path, "mkdir", side_effect=RuntimeError("boom")):
        result = create_standard_directories(tmp_path, dirs=["y"])
    assert len(result["errors"]) == 1
    assert "boom" in result["errors"][0]


def test_main_list_presets_exits_zero(capsys):
    with patch.object(sys, "argv", ["standardize_dirs.py", "--list-presets"]):
        with pytest.raises(SystemExit) as exc:
            main()
        assert exc.value.code == 0
    assert "可用的预设模板" in capsys.readouterr().out


def test_main_no_dirs_from_config_exits_one(tmp_path: Path):
    cfg = tmp_path / "nodirs.json"
    cfg.write_text(json.dumps({"dirs": []}), encoding="utf-8")
    with patch.object(sys, "argv", ["standardize_dirs.py", str(tmp_path), "-c", str(cfg)]):
        with pytest.raises(SystemExit) as exc:
            main()
        assert exc.value.code == 1


def test_main_unexpected_exception(tmp_path: Path):
    with patch(
        "standardize_dirs.get_directory_list",
        side_effect=RuntimeError("unexpected"),
    ):
        with patch.object(sys, "argv", ["standardize_dirs.py", str(tmp_path)]):
            with pytest.raises(SystemExit) as exc:
                main()
            assert exc.value.code == 1
