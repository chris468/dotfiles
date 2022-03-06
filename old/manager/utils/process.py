import subprocess
from typing import List, TextIO


class ProcessRunnerInterface:
    def run(self, cmd: List[str]) -> None:
        pass

    def run_get_output(self, cmd: List[str]) -> str:
        pass

    def run_in_background(self, cmd: List[str], output: TextIO) -> None:
        pass


class ProcessRunner(ProcessRunnerInterface):
    def _run(self, cmd: List[str], **kwargs
             ) -> subprocess.CompletedProcess:
        if not cmd:
            raise ValueError("must specify cmd")

        return subprocess.run(cmd, check=True, **kwargs)

    def run(self, cmd: List[str]) -> None:
        _ = self._run(cmd)

    def run_get_output(self, cmd: List[str]) -> str:
        result = self._run(cmd, capture_output=True)
        return result.stdout.decode('utf-8')

    def run_in_background(self, cmd: List[str], output: TextIO) -> None:
        subprocess.Popen(cmd, stdout=output, stderr=output)

