from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET


def extract_sql_from_xdmz(source_folder, output_folder):
    source = Path(source_folder)
    output = Path(output_folder)

    output.mkdir(parents=True, exist_ok=True)

    for xdmz_file in source.rglob("*.xdmz"):
        print(f"Scanning: {xdmz_file}")

        try:
            with zipfile.ZipFile(xdmz_file, "r") as archive:

                xdm_files = [
                    name for name in archive.namelist()
                    if name.lower().endswith(".xdm")
                ]

                if not xdm_files:
                    print("  No .xdm found")
                    continue

                for xdm_name in xdm_files:
                    print(f"  Reading: {xdm_name}")

                    xml_content = archive.read(xdm_name)

                    root = ET.fromstring(xml_content)

                    sql_nodes = [
                        elem
                        for elem in root.iter()
                        if elem.tag.split("}")[-1].lower() == "sql"
                    ]

                    if not sql_nodes:
                        print("  No SQL tags found")

                        # for elem in root.iter():
                        #     print(elem.tag)

                        continue

                    for idx, node in enumerate(sql_nodes, start=1):
                        sql_text = node.text

                        if not sql_text or not sql_text.strip():
                            continue

                        output_file = (
                            output /
                            f"{xdmz_file.stem}_{idx}.sql"
                        )

                        with open(output_file, "w", encoding="utf-8") as f:
                            f.write(sql_text.strip())

                        print(f"  Extracted -> {output_file}")

        except Exception as e:
            print(f"  Failed: {e}")


if __name__ == "__main__":
    extract_sql_from_xdmz(
        source_folder="Financials",
        output_folder="output_sql"
    )