from pathlib import Path

from pipeline.connection import get_connection

CSV_PATH = Path("data/raw/SHR76_25a.csv").resolve()


def main():
    with get_connection() as conn:
        cur = conn.cursor()
        print(f"Uploading {CSV_PATH.name}...")
        cur.execute(
            f"PUT 'file://{CSV_PATH}' @RAW.SHR_STAGE "
            "AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
        )
        for row in cur.fetchall():
            print(row)


if __name__ == "__main__":
    main()          