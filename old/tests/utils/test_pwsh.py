from manager.utils.pwsh import PwshProcess
import pytest
from tests.testutils import FakeProcessRunner


@pytest.fixture()
def runner() -> FakeProcessRunner:
    return FakeProcessRunner()


@pytest.fixture()
def pwsh(runner: FakeProcessRunner) -> PwshProcess:
    return PwshProcess(runner)


def test_pwsh_returns_none_if_not_found(
        runner: FakeProcessRunner,
        pwsh: PwshProcess):

    def raise_not_found():
        raise FileNotFoundError

    runner.callback = raise_not_found

    profile = pwsh.get_profile()

    assert profile is None
