import argparse
from manager.installer import Manager
from manager.utils.filesystem import FileSystem, FileSystemInterface, Mode
from manager.utils.git import GitProcess, GitProcessInterface
from manager.utils.process import ProcessRunner, ProcessRunnerInterface
from datetime import datetime, timedelta
from pathlib import Path
import sys
import traceback
from typing import List


def _now() -> str:
    return datetime.now().strftime("%c")


class Updater:
    def __init__(
            self,
            manager: Manager,
            mode: Mode,
            home: Path,
            apps: List[str],
            status_file: Path = None,
            completion_file: Path = None):

        repo_path = Path(__file__).parent.parent

        if not mode:
            raise ValueError("mode is required")
        self._mode: Mode = mode

        if not home:
            raise ValueError("home is required")
        self._home: Path = home

        self._apps = apps

        self._status_file = status_file
        self._completion_file = completion_file

        if not manager:
            raise ValueError("manager is required")
        self._manager: Manager = manager

        self.git: GitProcessInterface = GitProcess(
                ProcessRunner(),
                home,
                repo_path)

    def _write_status(self, message: str, is_error: bool = False):
        file = sys.stderr if is_error else sys.stdout
        print(message, file=file)

        if self._status_file:
            with open(self._status_file, 'w') as f:
                f.write(message)
                f.flush()

    def _update(self) -> bool:
        print("dotfiles are out of date. Updating...")
        try:
            self.git.pull()
            success = self._manager.install(
                    self._mode,
                    self._home,
                    self._apps)
            if not success:
                raise RuntimeError("installation failed")

            self._write_status(f'dotfiles updated on {_now()}.')
        except RuntimeError:
            message = f'failed to update dotfiles on {_now()}\n' \
                + traceback.format_exc()
            self._write_status(message, True)
            raise
        finally:
            if self._completion_file:
                self._completion_file.touch()

        return True

    def _report_up_to_date(self):
        message = f'dotfiles were up to date when checked on {_now()}.'
        self._write_status(message)

    def update(self) -> bool:
        if self.git.has_updates():
            return self._update()
        else:
            self._report_up_to_date()

        return True

    def add_commandline_arguments(
            parser: argparse.ArgumentParser,
            manager: Manager):
        parser.add_argument(
                '-s', '--status-file',
                type=Path,
                help='file to write update status summary')
        parser.add_argument(
                '-c', '--completion-file',
                type=Path,
                help='file to touch when update is complete')
        manager.add_commandline_arguments(parser)

    def get_options_from_commandline(
            arguments: argparse.Namespace,
            manager: Manager) -> dict:
        options = manager.get_options_from_commandline(
                arguments,
                default_mode=Mode.QUIET)
        options['status_file'] = arguments.status_file
        options['completion_file'] = arguments.completion_file
        return options


class AutoUpdater:
    def __init__(self,
                 interval_in_minutes: int,
                 log_file: Path,
                 status_file: Path,
                 completion_file: Path):
        self._interval = timedelta(minutes=interval_in_minutes)

        if not log_file:
            raise ValueError('log_file is required')
        self._logfile = log_file

        if not status_file:
            raise ValueError('status_file is required')
        self._status_file = status_file

        if not completion_file:
            raise ValueError('completion_file is required')
        self._completion_file = completion_file

        self._runner: ProcessRunnerInterface = ProcessRunner()

        self._filesystem: FileSystemInterface = FileSystem()

    def _should_update(self) -> bool:
        return self._filesystem.file_age(self._logfile) > self._interval

    def _update(self) -> None:
        self._status_file.parent.mkdir(parents=True, exist_ok=True)
        self._completion_file.unlink(missing_ok=True)

        with self._logfile.open('w') as f:
            print(f'Starting update at {_now()}', file=f)
            self._runner.run_in_background(
                    [
                        sys.executable,
                        '-m', 'manager',
                        'update',
                        '--quiet',
                        '--status-file', self._status_file,
                        '--completion-file', self._completion_file
                    ],
                    f)

    def _print_status(self) -> None:
        if self._status_file.exists():
            with open(self._status_file, 'r') as f:
                print(f.read())
        else:
            print('Dotfiles are up to date.')

    def autoupdate(self) -> bool:
        if self._should_update():
            print(
                f'Updating dotfiles in background. See {self._logfile}...')
            self._update()
            return True
        else:
            self._print_status()
            return False

    default_status_directory = Path.home() / '.cache' / 'dotfiles'
    default_log_file = default_status_directory / 'auto-update.log'
    default_status_file = default_status_directory / 'auto-update-status.txt'
    default_completion_file = default_status_directory / 'auto-update-complete'
    default_interval_in_minutes = 120

    def add_commandline_arguments(parser: argparse.ArgumentParser) -> None:
        parser.add_argument(
                '-s', '--status-file',
                type=Path,
                help='file to write update status summary',
                default=AutoUpdater.default_status_file)
        parser.add_argument(
                '-l', '--log-file',
                type=Path,
                help='file to write update log',
                default=AutoUpdater.default_log_file)
        parser.add_argument(
                '-c', '--completion-file',
                type=Path,
                help='file to create once update is complete',
                default=AutoUpdater.default_completion_file)
        parser.add_argument(
                '-i', '--interval_in_minutes',
                type=int,
                help='auto update interval',
                default=AutoUpdater.default_interval_in_minutes)

    def get_options_from_commandline(arguments) -> dict:
        return {arg: value
                for arg, value in vars(arguments).items()
                if arg != 'command'}
