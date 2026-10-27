import sys
from datetime import UTC, datetime
from pathlib import Path

from reporting.analytics_events.database import ANALYTICS_EVENTS_QUERY, ORGANISATIONS_QUERY, fetch_rows
from reporting.csv_output import write_csv as write_csv_rows

OUTPUT_DIR = Path(__file__).parent / "output"


def write_csv(rows: list[dict[str, object]], filename: str, output_dir: Path = OUTPUT_DIR) -> Path:
    """Write rows as a CSV with a header row, using the first row's keys as the column order."""
    if not rows:
        msg = f"no rows returned for {filename}"
        raise ValueError(msg)
    return write_csv_rows(rows, output_dir / filename)


def main() -> None:
    # Shared between both files so a single run's exports are easy to pair up.
    timestamp = datetime.now(UTC).strftime("%Y-%m-%d_%H-%M")
    analytics_events_path = write_csv(fetch_rows(ANALYTICS_EVENTS_QUERY), f"analytics_events_{timestamp}.csv")
    sys.stderr.write(f"Report written to {analytics_events_path}\n")
    organisations_path = write_csv(fetch_rows(ORGANISATIONS_QUERY), f"organisations_{timestamp}.csv")
    sys.stderr.write(f"Report written to {organisations_path}\n")


if __name__ == "__main__":
    main()
