#!/usr/bin/env python3
"""Simple app used by the assessment for local runs, CI, Docker, and Nomad."""

from __future__ import annotations

import os
import time
from datetime import datetime, timezone


def env_flag(name: str) -> bool:
    value = os.getenv(name, "")
    return value.lower() in {"1", "true", "yes", "on"}


def heartbeat_interval() -> int:
    try:
        return max(1, int(os.getenv("LOG_INTERVAL_SECONDS", "30")))
    except ValueError:
        return 30


def main() -> None:
    print("Hello, DevOps!", flush=True)

    if not env_flag("SERVICE_MODE"):
        return

    interval = heartbeat_interval()
    while True:
        timestamp = datetime.now(timezone.utc).isoformat()
        print(f"{timestamp} service heartbeat", flush=True)
        time.sleep(interval)


if __name__ == "__main__":
    main()

