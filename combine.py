import re, sys
from pathlib import Path

def combine(src):
    base = src.parent
    lines = src.read_text().splitlines()
    out = []
    for line in lines:
        m = re.match(r'^\s*#include\s+(\S+)', line)
        if m:
            inc = base / m.group(1)
            out.append(f"-- included: {m.group(1)}")
            out.extend(inc.read_text().splitlines())
        else:
            out.append(line)
    return "\n".join(out)

src = Path(sys.argv[1] if len(sys.argv) > 1 else "shootinator.p8")
out = src.with_name(src.stem + "_combined.p8")
out.write_text(combine(src))
print(f"written: {out}")
