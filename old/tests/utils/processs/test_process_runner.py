from manager.utils.process import ProcessRunner
import pytest
import sys

successful_command \
        = 'pwsh.exe -NoProfile -Command Write-Host success'.split() \
        if 'win32' == sys.platform \
        else 'echo success'.split()

failure_command \
        = 'pwsh.exe -NoProfile -Command Exit 1'.split() \
        if 'win32' == sys.platform \
        else 'false'.split()


@pytest.fixture()
def runner() -> ProcessRunner:
    return ProcessRunner()


def test_process_runner_run_success_does_not_throw(
        runner: ProcessRunner):
    runner.run(successful_command)


def test_process_runner_run_fail_throws(
        runner: ProcessRunner):
    with pytest.raises(Exception):
        runner.run(failure_command)


def test_process_runner_run_get_output_returns_output(
        runner: ProcessRunner):
    output = runner.run_get_output(successful_command)
    assert output.strip() == 'success'


def test_process_runner_run_get_output_fail_throws(
        runner: ProcessRunner):
    with pytest.raises(Exception):
        runner.run_get_output(failure_command)
