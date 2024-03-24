import sys
def test_version(expected_minor_version):
    pyver = sys.version_info
    print(f"Python version major:{pyver.major}, minor:{pyver.minor}")
    actual_minor_version = pyver.minor
    assert actual_minor_version == expected_minor_version, f"Failed {actual_minor_version=}, {expected_minor_version=}"


if __name__ =="__main__":
    test_version(expected_minor_version=int(sys.argv[1]))