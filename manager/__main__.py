import argparse
from manager.installer import (
        Discoverer,
        default_installers_package,
        default_installers_path,
        Manager)
from manager.updater import AutoUpdater, Updater
import sys
import traceback


def handle_command_line():
    def add_install_argument_parser(manager: Manager, subparsers):
        parser = subparsers.add_parser('install', help='Install dotfile links')
        manager.add_commandline_arguments(parser)

    def add_update_argument_parser(manager: Manager, subparsers):
        parser = subparsers.add_parser('update', help='Download updates')
        Updater.add_commandline_arguments(parser, manager)

    def add_auto_update_argument_parser(subparsers):
        parser = subparsers.add_parser(
            'auto-update',
            help='Download updates in the background.',
            description=('Automatically update in the background. Returns 0 '
                         + 'if update was started, or 1 if already up to '
                         + 'date.'))
        AutoUpdater.add_commandline_arguments(parser)

    def create_parser(manager: Manager) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(description="Manage dotfiles")
        subparsers = parser.add_subparsers(
                title='operations',
                description=("Operations for managing dotfiles. Pass -h to "
                             + "the operation for that operation's help"),
                help='operation to execute',
                dest='command',
                required=True)
        add_install_argument_parser(manager, subparsers)
        add_update_argument_parser(manager, subparsers)
        add_auto_update_argument_parser(subparsers)
        return parser

    def run_command(manager: Manager, args: argparse.Namespace) -> bool:
        if 'install' == args.command:
            options = manager.get_options_from_commandline(args)
            return manager.install(**options)
        elif 'update' == args.command:
            options = Updater.get_options_from_commandline(args, manager)
            updater = Updater(manager, **options)
            return updater.update()
        elif 'auto-update' == args.command:
            options = AutoUpdater.get_options_from_commandline(args)
            auto_updater = AutoUpdater(**options)
            return auto_updater.autoupdate()
        else:
            raise RuntimeError(f'unknown command: {args.command}')

    def create_manager() -> Manager:
        discoverer = Discoverer(default_installers_path,
                                default_installers_package)
        return Manager(discoverer, sys.platform)

    try:
        manager = create_manager()
        parser = create_parser(manager)
        args = parser.parse_args()
        succeeded = run_command(manager, args)
        succeeded or exit(1)
    except Exception:
        traceback.print_exc()
        exit(70)


handle_command_line()
