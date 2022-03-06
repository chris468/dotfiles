from manager.installer import Installer
from manager.utils.filesystem import Mode
from manager.utils.process import ProcessRunner
from manager.utils.git import GitProcess, GitProcessInterface
from pathlib import Path
from typing import Callable, List


class Git(Installer):
    _include_file = 'dotfiles-gitconfig'

    def __init__(self, platform: str):
        super().__init__(platform)
        self._git_factory: Callable[[Path], GitProcessInterface] \
            = lambda home_dir: GitProcess(ProcessRunner(), home_dir)
        self._include_path \
            = str(self.dotfiles_dir / f'git/{Git._include_file}')
        self.name = 'git'

    def get_simple_links(self) -> List[str]:
        return {
                '.config/git/ignore': 'git/ignore'
            }

    def _remove_duplicates(self, git: GitProcessInterface, includes: List[str]
                           ) -> None:
        duplicates = [
                    x for x in includes
                    if x != self._include_path and Git._include_file in x
                ]

        for duplicate in duplicates:
            git.remove_include(duplicate)

    def perform_installation(self, home_dir: Path, mode: Mode) -> None:
        git = self._git_factory(home_dir)
        includes = git.get_includes()
        self._remove_duplicates(git, includes)

        if self._include_path not in includes:
            git.add_include(self._include_path)
