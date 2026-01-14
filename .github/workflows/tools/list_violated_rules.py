from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def extract_violated_rules(xml_path: Path) -> list[str]:
    try:
        tree = ET.parse(xml_path)
    except FileNotFoundError:
        raise SystemExit(f"ERROR: File not found: {xml_path}")
    except ET.ParseError as e:
        raise SystemExit(f"ERROR: XML parse error in {xml_path}: {e}")

    root = tree.getroot()

    # Collect unique rules, preserving first-seen order.
    seen: set[str] = set()
    ordered: list[str] = []

    # These elements may appear nested; use .iter() to find them anywhere.
    for tag in ("StdViol", "FlowViol"):
        for elem in root.iter(tag):
            rule = elem.get("rule")
            if rule and rule not in seen:
                seen.add(rule)
                ordered.append(rule)

    return ordered


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Usage: python3 violated_rules.py /path/to/report.xml", file=sys.stderr)
        return 2

    xml_path = Path(argv[1])

    rules = extract_violated_rules(xml_path)
    print(",".join(rules))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))