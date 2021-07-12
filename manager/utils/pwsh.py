from manager.utils.process import ProcessRunnerInterface


class PwshProcessInterface:
    def get_profile() -> str:
        pass


class PwshProcess(PwshProcessInterface):
    def __init__(self, runner: ProcessRunnerInterface):
        if not runner:
            raise ValueError("runner must be specified")

        self._runner: ProcessRunnerInterface = runner

    def get_profile(self) -> str:
        try:
            result = self._runner.run_get_output([
                    'pwsh',
                    '-NoProfile',
                    '-Command',
                    'Write-Output',
                    '$PROFILE.CurrentUserAllHosts'])
            return result.strip()
        except FileNotFoundError:
            return None

