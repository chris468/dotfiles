from manager.installer import Installer
from manager.utils.filesystem import FileSystem, Mode
from manager.utils.process import ProcessRunner
from manager.utils.pwsh import PwshProcess, PwshProcessInterface
from pathlib import Path
from typing import Dict


class Powershell(Installer):
    _linux_default_profile = '.config/powershell/profile.ps1'

    _win32_default_profile = 'Documents/PowerShell/profile.ps1'

    def __init__(self, platform: str):
        super().__init__(platform)

        self._pwsh: PwshProcessInterface = PwshProcess(ProcessRunner())

        self.name = 'powershell'

        self._filesystem = FileSystem()

    def _get_default_profile(self, home_dir) -> Path:
        return \
            home_dir / Powershell._win32_default_profile \
            if self.platform == 'win32' \
            else home_dir / Powershell._linux_default_profile

    def _calculate_links(self, home_dir) -> Dict[Path, Path]:
        target = self.dotfiles_dir / 'powershell/Profile.ps1'
        link = Path(self._pwsh.get_profile()
                    or self._get_default_profile(home_dir))

        real_home_dir = Path.home()
        using_real_home_dir = home_dir == real_home_dir
        if not using_real_home_dir and not link.is_relative_to(home_dir):
            if link.is_relative_to(real_home_dir):
                link = home_dir / link.relative_to(real_home_dir)
            else:
                raise RuntimeError(
                    "Can't link powershell profile outside ~ when using "
                    + "custom home directory")

        return {link: target}

    def perform_installation(self, home_dir: Path, mode: Mode) -> None:
        links = self._calculate_links(home_dir)
        self._filesystem.create_links(links, mode)
