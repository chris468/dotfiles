from manager.utils.process import ProcessRunnerInterface
from typing import List


class VimProcessInterface:
    def install_plugins(self, clean: bool = False) -> None:
        pass


class VimProcess(VimProcessInterface):
    _clean_command = ['-c', 'PlugClean!']
    _install_command = ['-c', 'PlugInstall']
    _quit_command = ['-c', 'qa']

    def __init__(self, runner: ProcessRunnerInterface):
        if not runner:
            raise ValueError("must spcify runner")

        self._runner: ProcessRunnerInterface = runner

    def install_plugins(self, clean: bool = False) -> None:
        params: List[str] = []
        if clean:
            params.extend(VimProcess._clean_command)

        params.extend(VimProcess._install_command)
        params.extend(VimProcess._quit_command)

        try:
            self._runner.run(['vim', *params])
        except FileNotFoundError:
            # often on window only a .bat files is in the path
            self._runner.run(['vim.bat', *params])
