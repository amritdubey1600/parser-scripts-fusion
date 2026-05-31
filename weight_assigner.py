import json

with open("foreignKeys.json", "r", encoding="utf-8") as f:
    foreign_keys = json.load(f)

with open("joins.json", "r", encoding="utf-8") as f:
    joins = json.load(f)

# key -> unique edge identifier
weighted_edges = {}

def add_edge(edge, weight):
    key = (
        edge["fromTable"].upper(),
        edge["toTable"].upper(),
        edge["fromColumn"].upper(),
        edge["toColumn"].upper()
    )

    if key not in weighted_edges:
        weighted_edges[key] = {
            **edge,
            "weight": weight
        }
    else:
        # keep the smaller weight if duplicate appears
        weighted_edges[key]["weight"] = min(
            weighted_edges[key]["weight"],
            weight
        )

# Process foreign keys
for edge in foreign_keys:
    add_edge(edge, 1)

# Process joins
for file_name, file_joins in joins.items():
    for edge in file_joins:
        from_col = edge["fromColumn"].upper()
        to_col = edge["toColumn"].upper()

        if from_col.endswith("_ID") or to_col.endswith("_ID"):
            add_edge(edge, 1)
        else:
            add_edge(edge, 1.5)

result = list(weighted_edges.values())

with open("weightedJoins.json", "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2)

print(f"Generated weightedJoins.json with {len(result)} unique edges")