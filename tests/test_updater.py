import argparse
from manager.installer import Installer, Manager
from manager.utils.filesystem import Mode
from manager.utils.git import GitProcessInterface
from manager.updater import Updater
from tests import testutils
from pathlib import Path
import pytest
from typing import Callable

UpdaterFactory = Callable[[str], Updater]


def assert_status_file(write_status: bool, status_file: Path, content: str):
    if write_status:
        with open(status_file, "r") as f:
            lines = f.readlines()
            assert [message for message in lines if content in message]


class FakeInstaller(Installer):
    def __init__(self, name: str):
        super().__init__('platform')
        self.should_fail = False
        self.ran = False
        self.name = name

    def install(self, home_dir: Path, mode):
        self.ran = True
        if (self.should_fail):
            raise RuntimeError("simulated failure")


class FakeGitProcess(GitProcessInterface):
    def __init__(self):
        self.dirty: bool = False
        self.pulled: bool = False

    def has_updates(self) -> bool:
        return self.dirty

    def pull(self):
        self.pulled = True


@pytest.fixture()
def installer() -> FakeInstaller:
    return FakeInstaller('fake')


@pytest.fixture()
def git_process() -> FakeGitProcess:
    return FakeGitProcess()


@pytest.fixture()
def status_file(tmp_path: Path) -> Path:
    return tmp_path / 'status_file.log'


@pytest.fixture()
def updater_factory(
        tmp_path: Path,
        git_process: FakeGitProcess,
        installer: FakeInstaller) -> UpdaterFactory:
    def impl(status_file: str) -> Updater:
        home = tmp_path / 'home'
        home.mkdir()
        u = Updater(
                Manager(
                    testutils.FakeDiscoverer([installer]),
                    'platform'),
                Mode.ERROR,
                home,
                [],
                status_file)
        u.git = git_process
        return u

    return impl


@pytest.mark.parametrize('write_status', [(True), (False)])
def test_updater_does_not_update_when_already_up_to_date(
        updater_factory: UpdaterFactory,
        installer: FakeInstaller,
        git_process: FakeGitProcess,
        status_file: Path,
        write_status: bool):

    git_process.dirty = False
    updater = updater_factory(status_file if write_status else None)

    success = updater.update()

    assert success
    assert not git_process.pulled
    assert not installer.ran
    assert_status_file(write_status, status_file, 'up to date')


@pytest.mark.parametrize('write_status', [(True), (False)])
def test_updater_updates_when_out_of_date(
        updater_factory: UpdaterFactory,
        installer: FakeInstaller,
        git_process: FakeGitProcess,
        status_file: Path,
        write_status: bool):

    git_process.dirty = True
    updater = updater_factory(status_file if write_status else None)

    success = updater.update()

    assert success
    assert installer.ran
    assert_status_file(write_status, status_file, 'updated')


@pytest.mark.parametrize('write_status', [(True), (False)])
def test_updater_handles_error(
        updater_factory: UpdaterFactory,
        installer: FakeInstaller,
        git_process: FakeGitProcess,
        status_file: Path,
        write_status: bool):

    installer.should_fail = True
    git_process.dirty = True
    updater = updater_factory(status_file if write_status else None)

    with pytest.raises(RuntimeError, match=r'installation failed'):
        _ = updater.update()

    assert_status_file(write_status, status_file, 'installation failed')


def test_updater_parses_arguments():
    home = Path('/home/dir')
    status_file = home / 'status'
    discoverer = testutils.FakeDiscoverer([
        FakeInstaller('a'),
        FakeInstaller('b'),
        FakeInstaller('c')])
    manager = Manager(discoverer, 'platform')
    parser = argparse.ArgumentParser()
    Updater.add_commandline_arguments(parser, manager)
    arguments = parser.parse_args([
        '--home', str(home),
        '--status-file', str(status_file),
        '-f',
        '--apps', 'a', 'b'
        ])

    actual_options = Updater.get_options_from_commandline(arguments, manager)

    expected_options = {
            'home': home,
            'status_file': status_file,
            'mode': Mode.FORCE,
            'apps': ['a', 'b']
            }

    assert expected_options == actual_options


def test_updater_default_mode_is_quiet():
    manager = Manager(testutils.FakeDiscoverer([]), 'platform')
    parser = argparse.ArgumentParser()
    Updater.add_commandline_arguments(parser, manager)
    arguments = parser.parse_args([])

    actual_options = Updater.get_options_from_commandline(arguments, manager)

    assert Mode.QUIET == actual_options['mode']