import re
import sys
from pathlib import Path

patterns = ["@skip", "@note", "@fails"]

all_files = {}

def process_path(path: Path):
    # collect all lines from all files under the path
    lines = []
    for file in path.rglob("*.feature"):
        if file.is_file():
            try:
                with file.open("r", errors="ignore") as f:
                    lines.extend(f.readlines())
            except Exception:
                # skip unreadable files
                pass
    return lines

def analyze(lines):
    for s in patterns:
        data = all_files.setdefault(s, dict())
        for line in lines:
            if s in line:
                m = re.search(rf"{re.escape(s)} (@\S+( #https://github.com/kuzudb/kuzu/issues/\d+)?)", line)
                if m:
                    key = m.group(1)
                    data[key] = data.get(key, 0) + 1

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python stats.py <dir1> <dir2> ...")
        sys.exit(1)

    for dir_path in sys.argv[1:]:
        path = Path(dir_path)
        assert path.is_dir()
        lines = process_path(path)
        analyze(lines)

    for pattern, data in all_files.items():
        print(f"\n== {pattern} ==")
        counts = 0
        for k, v in sorted(data.items()):
            print(f"    {v:>3} {k}")
            counts += v
        print(f"    Total: {counts}")
