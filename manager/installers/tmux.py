from manager.installer import Installer
from typing import Dict, List


class Tmux(Installer):
    def __init__(self, platform: str):
        super().__init__(platform)
        self.name = 'tmux'

    def get_supported_platforms(self) -> List[str]:
        return ['linux']

    def get_simple_links(self) -> Dict[str, str]:
        return {
                '.tmux.conf': 'tmux/tmux.conf'
            }
