import time

START_TIME = time.time()


def uptime_seconds():
    return time.time() - START_TIME


def format_uptime(seconds):
    hours, rest = divmod(int(seconds), 3600)
    minutes, secs = divmod(rest, 60)
    return f"{hours}h {minutes}m {secs}s"


def compute_cost(hourly_rate, hours_per_day, days_per_month):
    return hourly_rate * hours_per_day * days_per_month


def storage_cost(disk_gb, price_per_gb=0.05):
    return disk_gb * price_per_gb


def total_cost(hourly_rate, hours_per_day, days_per_month, disk_gb):
    total = compute_cost(hourly_rate, hours_per_day, days_per_month) + storage_cost(disk_gb)
    return round(total, 2)