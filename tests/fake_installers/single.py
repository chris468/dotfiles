from manager.installer import Installer
from manager.utils.filesystem import Mode
from pathlib import Path


class InstallerA(Installer):
    def install(self, home_dir: Path, mode: Mode):
        pass
