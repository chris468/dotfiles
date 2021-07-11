from datetime import timedelta
from manager.installer import Installer, DiscovererInterface
from manager.utils.filesystem import FileSystemInterface, Mode
from manager.utils.process import ProcessRunnerInterface
from tests.fake_installers.single import InstallerA
from tests.fake_installers.multiple import Installer1, Installer2
from pathlib import Path
from typing import Callable, Dict, List, Tuple, TextIO

fake_installer_path: Path \
    = Path(__file__).parent / 'fake_installers'

fake_installer_package: str = 'tests.fake_installers'


def get_fake_installers() -> List[type]:
    return [InstallerA, Installer1, Installer2]


class FakeDiscoverer(DiscovererInterface):
    def __init__(self, installers: List[Installer]):
        self._installers: List[Installer] = installers or []

    def installers(self) -> List[Installer]:
        return self._installers


class FakeFileSystem(FileSystemInterface):
    def __init__(self):
        self.links: List[Dict[Path, Path]] = []
        self.ages: Dict[Path, int] = {}

    def create_links(self, links: Dict[Path, Path], mode: Mode) -> None:
        self.links.append(links)

    def file_age(self, path: Path) -> timedelta:
        return self.ages.get(path) or timedelta.max


class FakeProcessRunner(ProcessRunnerInterface):
    def __init__(self):
        super().__init__()

        self.log: List[List[str]] = []
        self.background_log: List[Tuple[List[str], TextIO]] = []
        self.output = ""
        self.callback: Callable[[], None] = None

    def run(self, cmd: List[str]) -> None:
        self.log.append(cmd)
        if self.callback:
            self.callback()

    def run_get_output(self, cmd: List[str]) -> str:
        self.run(cmd)
        return self.output

    def run_in_background(self, cmd: List[str], output: TextIO) -> None:
        self.background_log.append((cmd, output))
        if self.callback:
            self.callback()
