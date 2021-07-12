from manager.installers.vim import Vim
from manager.utils.filesystem import Mode
from manager.utils.vim import VimProcessInterface
from pathlib import Path
import pytest
from typing import Callable


class FakeVimProcess(VimProcessInterface):
    def __init__(self):
        self.last_clean = None

    def install_plugins(self, clean: bool) -> None:
        self.last_clean = clean


@pytest.fixture()
def home_dir(tmp_path: Path) -> Path():
    return tmp_path / 'home'


@pytest.fixture()
def vim_process() -> FakeVimProcess:
    return FakeVimProcess()


@pytest.fixture()
def create_vim(
        tmp_path: Path,
        vim_process: FakeVimProcess) -> Callable[[str], Vim]:

    def impl(platform: str) -> Vim:
        v = Vim(platform)
        v.vim = vim_process
        return v

    return impl


@pytest.mark.parametrize(
        'mode,should_clean',
        [(Mode.ERROR, False), (Mode.QUIET, False), (Mode.FORCE, True)])
def test_vim_installer_cleans_plugins_on_force(
        home_dir: Path,
        create_vim: Callable[[str], Vim],
        vim_process: FakeVimProcess,
        mode: Mode,
        should_clean: bool) -> None:

    vim = create_vim('platform')
    vim.perform_installation(home_dir, mode)

    assert should_clean == vim_process.last_clean


@pytest.mark.parametrize(
        'platform,install',
        [('win32', True), ('linux', False)])
def test_vim_installer_installs_windows_files_on_windows(
        create_vim: Callable[[str], Vim],
        vim_process: FakeVimProcess,
        platform: str,
        install: bool) -> None:

    vim = create_vim(platform)
    links = vim.get_simple_links()

    windows_files = {'_vimrc', 'vimfiles', '.vsvimrc'}
    installed_files = {t for t in links.keys()}
    installed_windows_files = windows_files.intersection(installed_files)

    if install:
        assert installed_windows_files == windows_files
    else:
        assert not installed_windows_files
