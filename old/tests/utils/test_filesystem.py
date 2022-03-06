from manager.utils.filesystem import FileSystem, Mode
from os import utime
from pathlib import Path
import pytest
from datetime import datetime, timedelta
from typing import Callable, Tuple


def assert_linked(dest: Path, target: Path) -> None:
    assert dest.exists()
    assert dest.is_symlink()
    assert dest.resolve() == target


@pytest.fixture()
def get_test_paths(tmp_path_factory) -> Callable[[str], Tuple[Path, Path]]:
    base = tmp_path_factory.mktemp("links")
    target = base / 'target'
    dest = base / 'dest'

    target.mkdir()
    dest.mkdir()

    def impl(name: str) -> Tuple[Path, Path]:
        return (target / name, dest / f'{name}-dest')

    return impl


def test_link_files_creates_links(
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetfile, dstfile = get_test_paths('a')
    targetdir, dstdir = get_test_paths('b')
    targetfile.touch()
    targetdir.mkdir()

    FileSystem().create_links({
            dstfile: targetfile,
            dstdir: targetdir
        },
        Mode.ERROR)

    assert_linked(dstfile, targetfile)
    assert_linked(dstdir, targetdir)


def test_link_files_fails_when_source_is_missing(
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetfile, dstfile = get_test_paths('a')
    targetdir, dstdir = get_test_paths('b')
    targetdir.mkdir()

    with pytest.raises(RuntimeError) as e:
        FileSystem().create_links({
                dstfile: targetfile,
                dstdir: targetdir
            },
            Mode.ERROR)

    assert not dstfile.exists()
    assert not dstdir.exists()
    assert str(targetfile) in str(e.value)
    assert str(targetdir) not in str(e.value)


def test_link_files_fails_when_destination_exists(
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetfile, dstfile = get_test_paths('a')
    targetdir, dstdir = get_test_paths('b')
    targetfile.touch()
    targetdir.mkdir()
    dstdir.mkdir()

    with pytest.raises(RuntimeError) as e:
        FileSystem().create_links({
                dstfile: targetfile,
                dstdir: targetdir
            },
            Mode.ERROR)

    assert not dstfile.exists()
    assert not dstdir.is_symlink()
    assert str(dstdir) in str(e.value)
    assert str(dstfile) not in str(e.value)


def test_link_files_quiet_skips_existing_destinations(
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetfile, dstfile = get_test_paths('a')
    targetdir, dstdir = get_test_paths('b')
    targetfile.touch()
    targetdir.mkdir()
    dstdir.mkdir()

    FileSystem().create_links({
            dstfile: targetfile,
            dstdir: targetdir
        },
        Mode.QUIET)

    assert_linked(dstfile, targetfile)
    assert not dstdir.is_symlink()


def test_link_files_force_overwrities_existing_destinations(
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetfile, dstfile = get_test_paths('a')
    targetdir, dstdir = get_test_paths('b')
    targetfile.touch()
    targetdir.mkdir()
    dstdir.mkdir()

    FileSystem().create_links({
            dstfile: targetfile,
            dstdir: targetdir
        },
        Mode.FORCE)

    assert_linked(dstfile, targetfile)
    assert_linked(dstdir, targetdir)


@pytest.mark.parametrize('target_exists', [(True), (False)])
def test_link_files_force_overwrites_existing_symlink(
        target_exists: bool,
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetdir, dstdir = get_test_paths('a')
    tmptarget, _ = get_test_paths('b')
    targetdir.mkdir()

    if target_exists:
        tmptarget.mkdir()

    dstdir.symlink_to(tmptarget)

    FileSystem().create_links({dstdir: targetdir}, Mode.FORCE)

    assert_linked(dstdir, targetdir)


def test_link_files_creates_destination_directory_if_not_present(
        get_test_paths: Callable[[str], Tuple[Path, Path]]) -> None:

    targetfile, dstfile = get_test_paths('a/b/c')
    targetfile.parent.mkdir(parents=True)
    targetfile.touch()

    FileSystem().create_links({
            dstfile: targetfile
        },
        Mode.ERROR)

    assert_linked(dstfile, targetfile)


def test_missing_file_age_is_max(tmp_path: Path):
    file = tmp_path / 'file'
    assert timedelta.max == FileSystem().file_age(file)


def test_file_age_returns_age(tmp_path: Path):
    file = tmp_path / 'file'
    file.touch()
    expected_age = timedelta(days=5)
    mtime = (datetime.now() - expected_age).timestamp()
    utime(file, (mtime, mtime))

    actual_age = FileSystem().file_age(file)
    tolerance = timedelta(minutes=5)
    assert abs(expected_age - actual_age) < tolerance
