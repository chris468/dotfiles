from manager.utils.process import ProcessRunnerInterface
from pathlib import Path
from typing import List


class GitProcessInterface:
    def get_includes(self) -> List[str]:
        pass

    def add_include(self, include: str) -> None:
        pass

    def remove_include(self, include: str) -> None:
        pass

    def has_updates(self) -> bool:
        pass

    def pull(self) -> None:
        pass


class GitProcess(GitProcessInterface):
    _git_command = 'git'
    _includes = 'include.path'

    def __init__(
            self,
            runner: ProcessRunnerInterface,
            home_dir: Path,
            repo_path: Path = None):
        if not runner:
            raise ValueError("must specify runner")
        self._runner: ProcessRunnerInterface = runner

        if not home_dir:
            raise ValueError("must specify home_dir")

        self._repo_path = repo_path

        self._repo_path_args: List[str] = ['-C', str(repo_path)] \
            if repo_path else []

        self._gitconfig = home_dir / '.gitconfig'
        self._config_command: str = ['config', '--file', str(self._gitconfig)]

    def _split_lines(text: str) -> List[str]:
        return text.strip().split('\n')

    def _run_git(self, cmd: List[str]) -> None:
        self._runner.run([GitProcess._git_command, *cmd])

    def _run_git_get_output(self, cmd: List[str]) -> str:
        return self._runner.run_get_output([GitProcess._git_command, *cmd])

    def get_includes(self) -> List[str]:
        if not self._gitconfig.exists():
            return []

        cmd = [
                *self._config_command,
                '--get-all',
                GitProcess._includes
              ]

        includes = self._run_git_get_output(cmd)

        return GitProcess._split_lines(includes)

    def add_include(self, include: str) -> None:
        cmd = [
                *self._config_command,
                '--add',
                GitProcess._includes,
                include
              ]

        self._run_git(cmd)

    def remove_include(self, include: str) -> None:
        cmd = [
                *self._config_command,
                '--unset',
                GitProcess._includes,
                include
               ]

        self._run_git(cmd)

    def _fetch(self):
        cmd = [*self._repo_path_args, 'fetch', 'origin']
        self._run_git(cmd)

    def _status(self) -> List[str]:
        cmd = self._repo_path_args + ['status', '--porcelain', '-b']
        status = self._run_git_get_output(cmd)
        return GitProcess._split_lines(status)

    def has_updates(self) -> bool:
        self._fetch()
        status = self._status()
        return bool([s for s in status if '[behind' in s])

    def pull(self):
        cmd = self._repo_path_args + ['pull']
        self._run_git(cmd)
