from utils import compute_cost, format_uptime, storage_cost, total_cost


def test_compute_cost():
    assert compute_cost(0.10, 8, 20) == 16.0


def test_storage_cost():
    assert storage_cost(100) == 5.0


def test_total_cost():
    assert total_cost(0.10, 8, 20, 100) == 21.0


def test_format_uptime():
    assert format_uptime(3725) == "1h 2m 5s"
    assert format_uptime(59) == "0h 0m 59s"