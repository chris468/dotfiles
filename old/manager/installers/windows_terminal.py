from manager.installer import Installer
from typing import Dict, List


class WindowsTerminal(Installer):
    def __init__(self, platform: str):
        super().__init__(platform)
        self.name = 'windows-terminal'

    def get_supported_platforms(self) -> List[str]:
        return ['win32']

    def get_simple_links(self) -> Dict[str, str]:
        packages = 'AppData/Local/Packages/'
        release = 'Microsoft.WindowsTerminal_8wekyb3d8bbwe'
        preview = 'Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe'
        settings = '/LocalState/settings.json'
        release_settings = packages + release + settings
        preview_settings = packages + preview + settings

        target = 'windows-terminal/settings.json'

        return {
                release_settings: target,
                preview_settings: target
            }
