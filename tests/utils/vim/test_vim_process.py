from manager.utils.vim import VimProcess
from tests.testutils import FakeProcessRunner
import pytest
from typing import List


def group_last_commands(runner: FakeProcessRunner) -> List[List[str]]:
    i = 0
    groups: List[List[str]] = []
    last_command = runner.log[-1]
    while i < len(last_command):
        current = last_command[i]
        is_command_start = current == '-c'
        i = i + 1
        i, next = (i + 1, last_command[i]) \
            if i < len(last_command) and is_command_start \
            else (i, None)
        groups += [[current, next]] if is_command_start else [[current]]

    return groups


@pytest.fixture()
def runner() -> FakeProcessRunner:
    return FakeProcessRunner()


@pytest.fixture()
def vim(runner: FakeProcessRunner) -> VimProcess:
    return VimProcess(runner)


@pytest.mark.parametrize('clean', [(False), (True)])
def test_vim_install_plugins_calls_vim(
        runner: FakeProcessRunner,
        vim: VimProcess,
        clean: bool) -> None:

    vim.install_plugins(False)

    assert 'vim' == runner.log[0][0]


@pytest.mark.parametrize('clean', [(False), (True)])
def test_vim_install_plugins_quits(
        runner: FakeProcessRunner,
        vim: VimProcess,
        clean: bool) -> None:

    vim.install_plugins(clean)

    commands = group_last_commands(runner)
    assert VimProcess._quit_command == commands[-1]


def test_vim_install_plugins_not_clean_doesnt_clean(
        runner: FakeProcessRunner,
        vim: VimProcess,) -> None:

    vim.install_plugins(False)

    commands = group_last_commands(runner)
    assert VimProcess._clean_command not in commands


def test_vim_install_plugins_clean_cleans_first(
        runner: FakeProcessRunner,
        vim: VimProcess,) -> None:

    vim.install_plugins(True)

    commands = group_last_commands(runner)
    install_index = commands.index(VimProcess._install_command)
    clean_index = commands.index(VimProcess._clean_command)
    assert clean_index < install_index
