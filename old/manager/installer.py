import argparse
from manager.utils.filesystem import FileSystem, Mode
import importlib
import inspect
from pathlib import Path
import pkgutil
import sys
from typing import Dict, List

default_installers_path: Path = Path(__file__).parent / 'installers'
default_installers_package: str = 'manager.installers'


class Installer:

    def __init__(self, platform: str):
        if not platform:
            raise ValueError("platform must be specified")

        self.platform: str = platform

        self.name: str = type(self).__name__

        self.dotfiles_dir: Path = \
            Path(__file__).parent.parent.resolve() / 'dotfiles'

        self._filesystem = FileSystem()

    def get_simple_links(self) -> Dict[str, str]:
        """
        Override to create links. Keys should be link destinations, relative to
        the user's home directory. Values are the link targets, relative to the
        dotfiles repo.
        """
        return {}

    def get_supported_platforms(self) -> List[str]:
        """
        If only certain platforms are supported, override to return a list of
        those platforms. Available platforms are the ones that can be returned
        by sys.platform. If the current platform is present in the list, the
        installer will be executed. Otherwise it will be skipped. Returning
        None or empty indicates all platforms are supported.
        """
        return {}

    def install(self, home_dir: Path, mode: Mode) -> None:
        """
        Installs the dotfiles by linking files and then performing additional
        installation. Avoid overriding this method, instead override
        perform_installation.
        """
        if not home_dir:
            raise ValueError("home_dir must be specified")

        supported_platforms = self.get_supported_platforms()
        if not supported_platforms or self.platform in supported_platforms:
            self._link_files(home_dir, mode)
            self.perform_installation(home_dir, mode)

    def _link_files(self, home_dir: Path, mode: Mode) -> None:
        links = {
                home_dir / src: self.dotfiles_dir / dest
                for src, dest in self.get_simple_links().items()
            }

        if links:
            self._filesystem.create_links(links, mode)

    def perform_installation(self, home_dir: Path, mode: Mode) -> None:
        pass


class DiscovererInterface:
    def installers() -> List[Installer]:
        pass


class Discoverer(DiscovererInterface):
    def __init__(self, path: Path, package: str):
        if not path:
            raise ValueError('path is required')

        if not package:
            raise ValueError('package is required')

        self._installers = Discoverer._discover(path, package)

    def installers(self):
        return self._installers

    def _discover(path: Path, package: str) -> List[Installer]:
        modules = [
                importlib.import_module(f'.{name}', package)
                for finder, name, ispkg
                in pkgutil.iter_modules([str(path)])
                if not ispkg
            ]

        installers = {
                obj
                for m in modules
                for _, obj in inspect.getmembers(m)
                if inspect.isclass(obj) and Installer in obj.__bases__
            }

        instances: List[Installer] = [
                installer(sys.platform)
                for installer
                in installers
            ]

        return instances


class Manager:
    def __init__(self, discoverer: DiscovererInterface, platform: str):
        self.installers = [c for c in discoverer.installers()
                           if self._is_supported_on_platform(c, platform)]
        self.mode: Mode = None
        self.home: Path = None

    def _is_supported_on_platform(self, installer: Installer, platform: str
                                  ) -> bool:
        supported_platforms = installer.get_supported_platforms()
        return not supported_platforms or platform in supported_platforms

    def install(self, mode: Mode, home: Path, apps: List[str]) -> bool:
        passed: bool = True
        for installer in [installer for installer in self.installers
                          if not apps or installer.name in apps]:
            try:
                installer.install(home, mode)
            except Exception as e:
                print(
                    f'Failed to install {installer.name}: {e}',
                    file=sys.stderr)
                passed = False

        return passed

    def _get_installer_names(self, installers: List[Installer]) -> List[str]:
        return [installer.name for installer in installers]

    def add_commandline_arguments(
            self,
            parser: argparse.ArgumentParser):
        parser.add_argument(
            '-f', '--force',
            action='store_true',
            help='Force install, overwriting any existing files')
        parser.add_argument(
            '-q', '--quiet',
            action='store_true',
            help='Quiet install, skipping any existing files. \
                    Ignored if --force.')
        parser.add_argument(
            '--home',
            type=Path,
            help='Override the home directory',
            default=str(Path.home()))

        parser.add_argument(
            '--apps',
            nargs='*',
            help='Apps to install dotfiles for. Default all.',
            choices=self._get_installer_names(self.installers))

    def get_options_from_commandline(
            self,
            arguments: argparse.Namespace,
            default_mode: Mode = Mode.ERROR
            ) -> dict:
        mode = default_mode
        if arguments.force:
            mode = Mode.FORCE
        elif arguments.quiet:
            mode = Mode.QUIET

        return {'mode': mode, 'home': arguments.home, 'apps': arguments.apps}
