"""Test sury's PHP installation"""


def test_php_sourcelist(host):
    """Check if php repository file exists"""
    f = host.file("/etc/apt/sources.list.d/php.list")

    assert f.exists
    assert f.user == "root"
    assert f.group == "root"
