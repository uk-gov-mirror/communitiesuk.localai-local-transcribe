"""Shared CSV-writing helper for the reporting packages (aggregate_analytics, analytics_events)."""

import csv
from collections.abc import Mapping, Sequence
from pathlib import Path


def write_csv(rows: Sequence[Mapping[str, object]], path: Path) -> Path:
    """Write rows as a CSV at path, creating parent directories if needed.

    The header row (and column order) is taken from the first row's keys. If rows is empty, an
    empty file is written (no header) - callers that consider an empty export an error should
    check for that themselves before calling this.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as file:
        if rows:
            writer = csv.DictWriter(file, fieldnames=list(rows[0].keys()))
            writer.writeheader()
            writer.writerows(rows)
    return path
