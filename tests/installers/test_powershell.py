from manager.installers.powershell import Powershell
from manager.utils.filesystem import Mode
from manager.utils.pwsh import PwshProcessInterface
from pathlib import Path
import pytest
from tests import testutils


class FakePowershellProcess(PwshProcessInterface):
    def __init__(self, home_dir: Path):
        super().__init__()
        self.profile = home_dir / 'dotfiles' / 'pwsh' / 'profile.ps1'

    def get_profile(self) -> str:
        return str(self.profile)


@pytest.fixture()
def home_dir(tmp_path: Path) -> Path:
    return tmp_path / 'home'


@pytest.fixture()
def pwsh_process(home_dir: Path) -> FakePowershellProcess:
    return FakePowershellProcess(home_dir)


@pytest.fixture()
def pwsh(pwsh_process: FakePowershellProcess) -> Powershell:
    p = Powershell('win32')
    p._pwsh = pwsh_process
    p._filesystem = testutils.FakeFileSystem()
    return p


def test_powershell_links_profile(
        home_dir: Path,
        pwsh: Powershell,
        pwsh_process: FakePowershellProcess
        ) -> None:

    pwsh.perform_installation(home_dir, Mode.ERROR)

    expected_target = [pwsh.dotfiles_dir / 'powershell/Profile.ps1']
    actual_target = [v
                     for links in pwsh._filesystem.links
                     for v in links.values()]
    assert expected_target == actual_target


def test_powershell_links_relative_to_specified_home_dir(
        home_dir: Path,
        pwsh_process: FakePowershellProcess,
        pwsh: Powershell):

    pwsh_process.profile = Path.home() / 'profile'
    pwsh.perform_installation(home_dir, Mode.ERROR)

    expected_link = [home_dir / 'profile']
    actual_link = [k
                   for links in pwsh._filesystem.links
                   for k in links.keys()]

    assert expected_link == actual_link


def test_powershell_fails_if_custom_home_set_and_profile_outside_home(
        home_dir: Path,
        pwsh_process: FakePowershellProcess,
        pwsh: Powershell):
    pwsh_process.profile = Path('/') / 'profile_dir' / 'profile'

    with pytest.raises(RuntimeError):
        pwsh.perform_installation(home_dir, Mode.ERROR)


def test_powershell_links_if_default_home_set_and_profile_outside_home(
        tmp_path: Path,
        pwsh_process: FakePowershellProcess,
        pwsh: Powershell):
    pwsh_process.profile = tmp_path / 'profile_dir' / 'profile'
    pwsh.perform_installation(Path.home(), Mode.ERROR)

    expected_link = [tmp_path / 'profile_dir' / 'profile']
    actual_link = [k
                   for links in pwsh._filesystem.links
                   for k in links.keys()]

    assert expected_link == actual_link
