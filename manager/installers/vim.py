from manager.installer import Installer
from manager.utils.filesystem import Mode
from manager.utils.process import ProcessRunner
from pathlib import Path
from typing import Dict

from manager.utils.vim import VimProcess, VimProcessInterface


class Vim(Installer):
    def __init__(self, platform: str):
        super().__init__(platform)
        self.vim: VimProcessInterface = VimProcess(ProcessRunner())
        self.name = 'vim'

    def get_simple_links(self) -> Dict[str, str]:
        links = {
                ".vim": "vim/vim",
                ".vimrc": "vim/vimrc"
                }

        if self.platform == 'win32':
            links = {
                    **links,
                    "_vimfiles": "vim/vim",
                    "_vimrc": "vim/vimrc",
                    ".vsvimrc": "vim/vsvimrc"
                }

        return links

    def perform_installation(self, home_dir: Path, mode: Mode):
        clean = mode == Mode.FORCE
        self.vim.install_plugins(clean)
