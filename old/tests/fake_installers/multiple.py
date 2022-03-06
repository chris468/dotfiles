from manager.installer import Installer
from manager.utils.filesystem import Mode
from pathlib import Path


class Installer1(Installer):
    def install(self, home_dir: Path, mode: Mode):
        pass


class Installer2(Installer):
    def install(self, home_dir: Path, mode: Mode):
        pass


class NotAInstaller:
    pass
