import json
from pathlib import Path

import sqlglot
from sqlglot import exp


def extract_joins(sql):
    try:
        tree = sqlglot.parse_one(sql, dialect="oracle")
    except Exception as e:
        print(f"  Failed to parse SQL: {e}")
        return []

    alias_map = {}

    # Build alias -> table mapping
    for table in tree.find_all(exp.Table):
        alias = table.alias

        if alias:
            alias_map[alias] = table.name
        else:
            alias_map[table.name] = table.name

    joins = []
    seen = set()

    # Find all column = column predicates
    for eq in tree.find_all(exp.EQ):

        left = eq.left
        right = eq.right

        if not (
            isinstance(left, exp.Column)
            and isinstance(right, exp.Column)
        ):
            continue

        left_alias = left.table
        right_alias = right.table

        if not left_alias or not right_alias:
            continue

        if left_alias not in alias_map or right_alias not in alias_map:
            continue

        left_table = alias_map.get(left_alias, left_alias)
        right_table = alias_map.get(right_alias, right_alias)

        if '_' not in left_table or '_' not in right_table:
            continue

        join_info = {
            "fromTable": left_table,
            "toTable": right_table,
            "fromColumn": left.name,
            "toColumn": right.name,
        }

        key = (
            left_table,
            right_table,
            left.name,
            right.name,
        )

        if "attribute" in join_info["fromColumn"].lower() or "attribute" in join_info["toColumn"].lower():
            continue

        if key not in seen:
            seen.add(key)
            joins.append(join_info)

    return joins


def main():
    queries_dir = Path("queries")

    if not queries_dir.exists():
        print("queries folder not found")
        return

    all_results = {}

    sql_files = sorted(queries_dir.glob("*.sql"))

    print(f"Found {len(sql_files)} SQL files\n")

    for sql_file in sql_files:
        print(f"Scanning: {sql_file.name}")

        try:
            sql = sql_file.read_text(
                encoding="utf-8",
                errors="ignore"
            )

            joins = extract_joins(sql)

            all_results[sql_file.name] = joins

            print(f"  Found {len(joins)} joins")

        except Exception as e:
            print(f"  Error: {e}")
            all_results[sql_file.name] = []

    output_file = "joins.json"

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_results, f, indent=2)

    print(f"\nSaved results to {output_file}")


if __name__ == "__main__":
    main()