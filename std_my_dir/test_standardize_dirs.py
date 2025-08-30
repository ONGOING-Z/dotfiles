import os
import shutil
from pathlib import Path

from standardize_dirs import create_standard_directories


def test_dry_run_creates_nothing(tmp_path: Path):
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
    result = create_standard_directories(tmp_path)
    for name in ("project", "archive", "discard"):
        assert (tmp_path / name).is_dir()
    assert len(result["errors"]) == 0
