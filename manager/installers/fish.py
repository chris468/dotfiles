from manager.installer import Installer
from typing import Dict, List


class FishInstaller(Installer):
    def __init__(self, platform: str):
        super().__init__(platform)
        self.name = 'fish'

    def get_supported_platforms(self) -> List[str]:
        return ['linux']

    def get_simple_links(self) -> Dict[str, str]:
        return {
                '.config/fish': 'fish/fish'
               }
