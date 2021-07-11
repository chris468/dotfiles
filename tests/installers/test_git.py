from manager.installers.git import Git
from manager.utils.filesystem import Mode
from manager.utils.git import GitProcessInterface
from pathlib import Path
import pytest
from typing import List


class FakeGitProcess(GitProcessInterface):
    def __init__(self):
        self.includes: List[str] = []
        self.removed: List[str] = []
        self.added: List[str] = []

    def get_includes(self) -> List[str]:
        return self.includes or []

    def add_include(self, include: str) -> None:
        self.added.append(include)

    def remove_include(self, include: str) -> None:
        self.removed.append(include)


@pytest.fixture()
def home_dir(tmp_path: Path) -> Path:
    return tmp_path / 'home'


@pytest.fixture()
def git_process() -> FakeGitProcess:
    return FakeGitProcess()


@pytest.fixture()
def git(git_process: FakeGitProcess) -> Git:
    g = Git('platform')
    g._git_factory = lambda home_dir: git_process
    return g


def test_git_installer_adds_include_if_not_present(
        home_dir: Path,
        git: Git,
        git_process: FakeGitProcess) -> None:

    git_process.includes = ['/test/1', '/test/2']

    git.perform_installation(home_dir, Mode.ERROR)

    assert [git._include_path] == git_process.added


def test_git_installer_does_not_add_include_if_present(
        home_dir: Path,
        git: Git,
        git_process: FakeGitProcess) -> None:

    git_process.includes = ['/test/1', git._include_path, '/test/2']

    git.perform_installation(home_dir, Mode.ERROR)

    assert not git_process.added


def test_git_installer_removes_duplicates(
        home_dir: Path,
        git: Git,
        git_process: FakeGitProcess) -> None:

    git_process.includes = [
               f'/test/1/{Git._include_file}',
               '/test/2/x',
               f'/test/2/{Git._include_file}'
               f'{git._include_path}'
           ]
    duplicates = git_process.includes[0::2]

    git.perform_installation(home_dir, Mode.ERROR)

    assert duplicates == git_process.removed
