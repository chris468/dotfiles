import argparse
from collections import Counter
from manager.installer import Installer, Manager
from manager.utils.filesystem import Mode
from tests import testutils
from pathlib import Path
import pytest
import sys
from typing import Dict, List


class FakeInstaller(Installer):
    def __init__(self, platform: str, name: str = None, **kwargs):
        super().__init__(platform)
        self._simple_links = kwargs.get('simple_links') or {}
        self._supported_platforms = kwargs.get('supported_platforms')
        self.mode: Mode = None
        self.ran = False

        if name:
            self.name = name

        self._filesystem = testutils.FakeFileSystem()

    def get_supported_platforms(self) -> List[str]:
        return self._supported_platforms

    def get_simple_links(self) -> Dict[str, str]:
        return self._simple_links

    def perform_installation(self, home_path: Path, mode: Mode) -> None:
        self.ran = True
        self.mode = mode


@pytest.fixture()
def home_dir(tmp_path: Path) -> Path:
    return tmp_path / 'home'


def test_installer_creates_simple_links(home_dir: Path) -> None:
    simple_links = {'test': '../tests/test_installer.py'}
    installer = FakeInstaller(sys.platform, simple_links=simple_links)

    installer.install(home_dir, Mode.ERROR)

    expected_link = home_dir / 'test'
    expected_target = '../tests/test_installer.py'
    expected_links = [{
        expected_link: installer.dotfiles_dir / expected_target}]
    actual_links = installer._filesystem.links
    assert expected_links == actual_links


def test_installer_calls_perform_installation(home_dir: Path) -> None:
    installer = FakeInstaller(sys.platform)

    installer.install(home_dir, Mode.QUIET)

    assert Mode.QUIET == installer.mode


def test_installer_runs_for_supported_platform(home_dir: Path) -> None:
    supported_platforms = ['your_platform', 'my_platform', 'our_platform']
    installer = FakeInstaller('my_platform',
                              supported_platforms=supported_platforms)

    installer.install(home_dir, Mode.QUIET)

    assert installer.ran


def test_installer_does_not_run_for_unsupported_platform(
        home_dir: Path) -> None:
    supported_platforms = ['your_platform', 'my_platform', 'our_platform']
    installer = FakeInstaller('their_platform',
                              supported_platforms=supported_platforms)

    installer.install(home_dir, Mode.QUIET)

    assert not installer.ran


@pytest.mark.parametrize('mode', [(Mode.ERROR), (Mode.QUIET), (Mode.FORCE)])
def test_install_runs_all_installers(home_dir: Path, mode: Mode):
    installers = [
            FakeInstaller('platform'),
            FakeInstaller('platform')]
    manager = Manager(
            testutils.FakeDiscoverer(installers),
            'platfrorm')

    passed = manager.install(
        testutils.FakeDiscoverer(installers),
        'platform',
        [])

    assert passed
    assert ([installer for installer in installers if installer.ran]
            == installers)


@pytest.mark.parametrize(
        'arguments,expected_mode',
        [
            ([], Mode.ERROR),
            (['-q'], Mode.QUIET),
            (['--quiet'], Mode.QUIET),
            (['-f'], Mode.FORCE),
            (['--force'], Mode.FORCE),
            (['-f', '-q'], Mode.FORCE),
            (['-q', '-f'], Mode.FORCE)
        ])
def test_installer_commandline_mode(
        arguments: List[str],
        expected_mode: Mode) -> None:

    manager = Manager(
            testutils.FakeDiscoverer([]),
            'platform')
    parser = argparse.ArgumentParser()
    manager.add_commandline_arguments(parser)
    arguments = parser.parse_args(arguments)

    options = manager.get_options_from_commandline(
            arguments)
    actual_mode = options['mode']

    assert expected_mode == actual_mode


def test_installer_runs_all_installers_by_default(home_dir: Path):
    installers = [
            FakeInstaller('platform', 'c1'),
            FakeInstaller('platform', 'c2'),
            FakeInstaller('platform', 'c3')
        ]
    discoverer = testutils.FakeDiscoverer(installers)
    manager = Manager(discoverer, 'platform')
    parser = argparse.ArgumentParser()
    manager.add_commandline_arguments(parser)
    arguments = parser.parse_args([])
    options = manager.get_options_from_commandline(
            arguments,
            Mode.QUIET)

    manager.install(
            options['mode'],
            home_dir,
            [])

    assert Counter(installers) \
        == Counter([installer for installer in installers if installer.ran])


@pytest.mark.parametrize('name', [("c1"), ("c2"), ("c3")])
def test_installer_runs_installers_by_name(name: str, home_dir: Path):
    installers = {installer.name: installer for installer in [
            FakeInstaller('platform', 'c1'),
            FakeInstaller('platform', 'c2'),
            FakeInstaller('platform', 'c3')
            ]}
    discoverer = testutils.FakeDiscoverer(list(installers.values()))
    manager = Manager(discoverer, 'platform')
    parser = argparse.ArgumentParser()
    manager.add_commandline_arguments(parser)
    arguments = parser.parse_args(['--app', name, '--home', str(home_dir)])
    options = manager.get_options_from_commandline(arguments, Mode.QUIET)

    manager.install(**options)

    assert installers[name].ran
    assert not [installer
                for installer
                in installers.values()
                if installer.name != name and installer.ran]


def test_installer_runs_multiple_installers_by_name(
        home_dir: Path):
    installers = {installer.name: installer for installer in [
            FakeInstaller('platform', 'c1'),
            FakeInstaller('platform', 'c2'),
            FakeInstaller('platform', 'c3')
            ]}
    discoverer = testutils.FakeDiscoverer(list(installers.values()))
    manager = Manager(discoverer, 'platform')
    parser = argparse.ArgumentParser()
    manager.add_commandline_arguments(parser)
    arguments = parser.parse_args([
        '--home', str(home_dir),
        '--app', 'c1', 'c3'])
    options = manager.get_options_from_commandline(arguments, Mode.QUIET)

    manager.install(**options)

    assert installers['c1'].ran
    assert not installers['c2'].ran
    assert installers['c3'].ran


def test_installer_default_name_is_class_name():
    class InstallerDefaultName(Installer):
        pass

    installer = InstallerDefaultName('platform')

    assert 'InstallerDefaultName' == installer.name


def test_installer_can_override_name():
    class InstallerOverriddenName(Installer):
        def __init__(self, platform: str):
            super().__init__(platform)
            self.name = 'test'

    installer = InstallerOverriddenName('platform')

    assert 'test' == installer.name
