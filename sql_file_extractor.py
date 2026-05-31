from pathlib import Path
import shutil

def copy_sql_files(source_folder, output_folder):
    source = Path(source_folder)
    output = Path(output_folder)

    output.mkdir(parents=True, exist_ok=True)

    count = 0

    for sql_file in source.rglob("*.sql"):
        print(f"Copying: {sql_file}")

        destination = output / sql_file.name

        # Handle duplicate filenames
        if destination.exists():
            stem = sql_file.stem
            suffix = sql_file.suffix
            idx = 1

            while destination.exists():
                destination = output / f"{stem}_{idx}{suffix}"
                idx += 1

        shutil.copy2(sql_file, destination)
        count += 1

    print(f"\nCopied {count} SQL files to {output}")

if __name__ == "__main__":
    copy_sql_files(
        source_folder="Oracle-SQL-Queries-master",
        output_folder="output_sql"
    )