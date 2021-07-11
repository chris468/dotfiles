from manager.utils.git import GitProcess
from pathlib import Path
import pytest
from tests.testutils import FakeProcessRunner


@pytest.fixture()
def home_dir(tmp_path: Path) -> Path:
    return tmp_path / 'home_dir'


@pytest.fixture()
def gitconfig(home_dir: Path) -> str:
    return str(home_dir / '.gitconfig')


@pytest.fixture()
def runner() -> FakeProcessRunner:
    return FakeProcessRunner()


@pytest.fixture()
def git(runner: FakeProcessRunner, home_dir: Path) -> GitProcess:
    return GitProcess(runner, home_dir)


def test_git_includes_runs_git_if_gitinclude_present(
        runner: FakeProcessRunner,
        git: GitProcess,
        gitconfig: str):

    Path(gitconfig).parent.mkdir()
    Path(gitconfig).touch()

    _ = git.get_includes()

    assert runner.log == [
                f'git config --file {gitconfig} --get-all include.path'.split()
            ]


def test_git_includes_returns_empty_if_gitconfig_missing(
        runner: FakeProcessRunner,
        git: GitProcess,
        gitconfig: str):

    result = git.get_includes()

    assert result == []


def test_git_add_include_runs_git(
        runner: FakeProcessRunner,
        git: GitProcess,
        gitconfig: str):

    git.add_include('/include/path')

    assert runner.log == [
        f'git config --file {gitconfig} --add include.path /include/path'
        .split()
    ]


def test_git_remove_include_runs_git(
        runner: FakeProcessRunner,
        git: GitProcess,
        gitconfig: str):

    git.remove_include('/include/path')

    assert runner.log == [
        f'git config --file {gitconfig} --unset include.path /include/path'
        .split()
    ]


def test_git_has_updates_with_current_directory(
        runner: FakeProcessRunner,
        git: GitProcess):
    _ = git.has_updates()

    expected_commands = [
            'git fetch origin'.split(),
            'git status --porcelain -b'.split()]
    actual_commands = runner.log
    assert expected_commands == actual_commands


def test_git_has_updates_with_repo_directory(
        runner: FakeProcessRunner,
        home_dir: Path):
    repo_path = Path("/repo/path")
    git = GitProcess(runner, home_dir, repo_path)
    _ = git.has_updates()

    expected_commands = [
            f'git -C {repo_path} fetch origin'.split(),
            f'git -C {repo_path} status --porcelain -b'.split()]
    actual_commands = runner.log
    assert expected_commands == actual_commands


def test_git_pull_with_current_directory(
        runner: FakeProcessRunner,
        git: GitProcess):
    _ = git.pull()

    expected_commands = ['git pull'.split()]
    actual_commands = runner.log
    assert expected_commands == actual_commands


def test_git_pull_with_repo_directory(
        runner: FakeProcessRunner,
        home_dir: Path):
    repo_path = Path("/repo/path")
    git = GitProcess(runner, home_dir, repo_path)
    _ = git.pull()

    expected_commands = [f'git -C {repo_path} pull'.split()]
    actual_commands = runner.log
    assert expected_commands == actual_commands


up_to_date_with_modifications = """## refactor-python...origin/refactor-python
M  installer/dotfiles/utils/git.py
MM installer/tests/utils/git/test_git_process.py
"""

up_to_date_clean = """## main...origin/main
"""

behind = """## main...origin/main [behind 1]
"""


@pytest.mark.parametrize(
        'status,expected_has_updates', [
            (up_to_date_clean, False),
            (up_to_date_with_modifications, False),
            (behind, True)
        ])
def test_git_has_updates_parses_status(
        status: str,
        expected_has_updates: bool,
        runner: FakeProcessRunner,
        git: GitProcess):

    runner.output = status

    actual_has_updates = git.has_updates()

    assert expected_has_updates == actual_has_updates
