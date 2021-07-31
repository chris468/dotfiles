import argparse
from datetime import timedelta
from manager.updater import AutoUpdater
from pathlib import Path
import pytest
import sys
from tests.testutils import FakeFileSystem, FakeProcessRunner


@pytest.fixture()
def filesystem() -> FakeFileSystem:
    return FakeFileSystem()


@pytest.fixture()
def log_file(tmp_path: Path) -> Path:
    return tmp_path / 'log.txt'


@pytest.fixture()
def status_file(tmp_path: Path) -> Path:
    return tmp_path / 'status.txt'


@pytest.fixture()
def completion_file(tmp_path: Path) -> Path:
    return tmp_path / 'complete'


@pytest.fixture()
def runner() -> FakeProcessRunner:
    return FakeProcessRunner()


@pytest.fixture()
def auto_updater(
        filesystem: FakeFileSystem,
        runner: FakeProcessRunner,
        log_file: Path,
        status_file: Path,
        completion_file: Path):
    a = AutoUpdater(5, log_file, status_file, completion_file)
    a._filesystem = filesystem
    a._runner = runner
    return a


def test_auto_updater_updates_when_out_of_date(
        filesystem: FakeFileSystem,
        auto_updater: AutoUpdater,
        log_file: Path):
    filesystem.ages[log_file] = timedelta(minutes=6)

    started = auto_updater.autoupdate()

    assert started


def test_auto_updater_starts_process_in_background(
        filesystem: FakeFileSystem,
        runner: FakeProcessRunner,
        auto_updater: AutoUpdater,
        status_file: Path,
        completion_file: Path,
        log_file: Path):
    filesystem.ages[log_file] = timedelta(minutes=6)

    _ = auto_updater.autoupdate()

    assert 1 == len(runner.background_log)
    actual_cmd, actual_file = runner.background_log[0]

    expected_cmd = [sys.executable,
                    '-m', 'manager',
                    'update',
                    '--quiet',
                    '--status-file', status_file,
                    '--completion-file', completion_file]
    assert expected_cmd == actual_cmd

    assert actual_file


def test_auto_updater_does_not_update_when_up_to_date(
        filesystem: FakeFileSystem,
        auto_updater: AutoUpdater,
        status_file: Path,
        log_file: Path):
    status_file.touch()
    filesystem.ages[log_file] = timedelta(minutes=4)

    started = auto_updater.autoupdate()

    assert not started


def test_auto_updater_ignores_missing_status_file_when_up_to_date(
        filesystem: FakeFileSystem,
        auto_updater: AutoUpdater,
        log_file: Path,
        capsys):
    filesystem.ages[log_file] = timedelta(minutes=4)

    _ = auto_updater.autoupdate()

    expected_output = 'Dotfiles are up to date.'
    actual_output, _ = capsys.readouterr()
    assert expected_output == actual_output.strip()


def test_auto_updater_prints_status_file_when_up_to_date(
        filesystem: FakeFileSystem,
        auto_updater: AutoUpdater,
        log_file: Path,
        status_file: Path,
        capsys):

    expected_output = 'file contents'
    status_file.write_text(expected_output)
    filesystem.ages[log_file] = timedelta(minutes=4)

    _ = auto_updater.autoupdate()

    actual_output, _ = capsys.readouterr()
    assert expected_output == actual_output.strip()


def test_auto_updater_deletes_completion_file_before_starting(
        filesystem: FakeFileSystem,
        runner: FakeProcessRunner,
        auto_updater: AutoUpdater,
        completion_file: Path):
    def assert_does_not_exist(path: Path):
        assert not path.exists()

    completion_file.touch()
    unexpected_path = completion_file
    runner.callback = lambda: assert_does_not_exist(unexpected_path)

    _ = auto_updater.autoupdate()


def test_auto_updater_does_not_recreate_completion_file_after_forking(
        filesystem: FakeFileSystem,
        runner: FakeProcessRunner,
        auto_updater: AutoUpdater,
        completion_file: Path):
    def assert_does_not_exist(path: Path):
        assert not path.exists()

    completion_file.touch()

    _ = auto_updater.autoupdate()

    unexpected_path = completion_file
    assert_does_not_exist(unexpected_path)


def test_auto_updater_parsers_arguments(
        status_file: Path,
        log_file: Path,
        completion_file: Path):
    parser = argparse.ArgumentParser()
    AutoUpdater.add_commandline_arguments(parser)
    args = parser.parse_args([
            '-s', str(status_file),
            '-l', str(log_file),
            '-c', str(completion_file),
            '-i', str(15)
        ])

    actual_options = AutoUpdater.get_options_from_commandline(args)

    expected_options = {
            'status_file': status_file,
            'log_file': log_file,
            'completion_file': completion_file,
            'interval_in_minutes': 15
        }
    assert expected_options == actual_options


def test_auto_updater_has_default_argument_values():
    parser = argparse.ArgumentParser()
    AutoUpdater.add_commandline_arguments(parser)
    args = parser.parse_args([])

    actual_options = AutoUpdater.get_options_from_commandline(args)

    expected_options = {
            'status_file': AutoUpdater.default_status_file,
            'log_file': AutoUpdater.default_log_file,
            'completion_file': AutoUpdater.default_completion_file,
            'interval_in_minutes': AutoUpdater.default_interval_in_minutes
        }
    assert expected_options == actual_options


@pytest.mark.parametrize(
        'default_path',
        [(AutoUpdater.default_log_file), (AutoUpdater.default_status_file)])
def test_default_paths_relative_to_default_status_directory(
        default_path: Path):
    assert default_path.relative_to(AutoUpdater.default_status_directory)

