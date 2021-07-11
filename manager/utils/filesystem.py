from enum import Enum
from pathlib import Path
import shutil
from datetime import datetime, timedelta
from typing import Dict, List


class Mode(Enum):
    ERROR = 1,
    QUIET = 2,
    FORCE = 3


class FileSystemInterface:
    def create_links(self, links: Dict[Path, Path], mode: Mode) -> None:
        pass

    def file_age(self, path: Path) -> timedelta:
        pass


class FileSystem:
    def _verify_targets_exist(self, targets: List[Path]) -> None:
        missing: List[str] = []
        for source in targets:
            if not source.exists():
                missing.append(str(source))

        if missing:
            missing.insert(0, "Missing source files:")
            raise RuntimeError("\n\t".join(missing))

    def _verify_destinations_do_not_exist(self, destinations: List[Path]
                                          ) -> None:
        exist: List[str] = []
        for destination in destinations:
            if destination.exists():
                exist.append(str(destination))

        if exist:
            exist.insert(0, "Destinations already present:")
            raise RuntimeError("\n\t".join(exist))

    def _remove_existing_destinations(self, destinations: List[Path]) -> None:
        for destination in destinations:
            if destination.is_dir() and not destination.is_symlink():
                shutil.rmtree(destination)
            elif destination.exists() or destination.is_symlink():
                destination.unlink()

    def _create_links(self, links: Dict[Path, Path], mode: Mode) -> None:
        for destination, target in links.items():
            if mode != Mode.QUIET or not destination.exists():
                destination_parent = destination.parent
                if not destination_parent.exists():
                    destination_parent.mkdir(parents=True)
                destination.symlink_to(target)

    def create_links(self, links: Dict[Path, Path], mode: Mode) -> None:
        targets = links.values()
        destinations = links.keys()

        self._verify_targets_exist(targets)

        if mode == Mode.ERROR:
            self._verify_destinations_do_not_exist(destinations)

        if mode != Mode.QUIET:
            self._remove_existing_destinations(destinations)

        self._create_links(links, mode)

    def file_age(self, path: Path) -> timedelta:
        if path.exists():
            mtime = datetime.fromtimestamp(path.stat().st_mtime)
            return datetime.now() - mtime

        return timedelta.max
