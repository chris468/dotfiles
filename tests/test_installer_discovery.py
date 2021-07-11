from collections import Counter
from manager.installer import Discoverer
from tests import testutils
from pathlib import Path


def test_discoverer_returns_all_and_only_installers(tmp_path: Path):
    discoverer = Discoverer(
            testutils.fake_installer_path,
            testutils.fake_installer_package)
    installers = discoverer.installers()

    expected_installers = Counter(testutils.get_fake_installers())
    actual_installers = Counter([type(installer) for installer in installers])
    assert expected_installers == actual_installers


def test_discoverer_returns_only_installers_for_current_platform():
    pass
