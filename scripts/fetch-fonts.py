#!/usr/bin/env python3
"""fetch-fonts.py — install the fonts Mat Shell ships, for development (the package installs the same files).

Usage:
  python3 scripts/fetch-fonts.py                 # download into ${XDG_DATA_HOME:-~/.local/share}/fonts/mat-shell
  python3 scripts/fetch-fonts.py --dest DIR      # somewhere else
  python3 scripts/fetch-fonts.py --check         # no network: exit 1 unless every file is present and matches

Files, pinned URLs and SHA-256 sums come from packaging/dependencies.json `fonts`. A download whose checksum
does not match is discarded. Licence texts are saved beside the fonts. JetBrains Mono comes from the
distribution package (ttf-jetbrains-mono), not from here.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "packaging" / "dependencies.json"


def default_dest():
    data = os.environ.get("XDG_DATA_HOME", "")
    base = Path(data) if data.startswith("/") else Path.home() / ".local" / "share"
    return base / "fonts" / "mat-shell"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def licence_name(font):
    return "LICENSE-" + font["family"].replace(" ", "") + ".txt"


def download(url, dest):
    """Fetch url to a temporary file beside dest (curl when present: it uses the system's CA store)."""
    fd, name = tempfile.mkstemp(dir=dest.parent)
    os.close(fd)
    tmp = Path(name)
    try:
        if shutil.which("curl"):
            subprocess.run(["curl", "-fsSL", "--max-time", "300", "-o", str(tmp), url], check=True)
        else:
            with urllib.request.urlopen(url, timeout=300) as r, tmp.open("wb") as out:
                shutil.copyfileobj(r, out)
    except (OSError, subprocess.CalledProcessError) as e:
        tmp.unlink(missing_ok=True)
        print(f"ERROR: download failed: {url}: {e}")
        sys.exit(1)
    return tmp


def main(argv):
    fonts = json.loads(MANIFEST.read_text(encoding="utf-8"))["fonts"]
    dest = Path(argv[argv.index("--dest") + 1]) if "--dest" in argv else default_dest()
    if "--check" in argv:
        bad = [f["file"] for f in fonts if not (dest / f["file"]).exists() or sha(dest / f["file"]) != f["sha256"]]
        for f in fonts:
            print(f"  {'MISSING' if f['file'] in bad else 'ok     '} {f['file']}")
        if bad:
            print(f"ERROR: {len(bad)} font file(s) missing or changed in {dest}; run python3 scripts/fetch-fonts.py")
            sys.exit(1)
        print(f"  ✓ fonts: {len(fonts)} files in {dest}")
        return
    dest.mkdir(parents=True, exist_ok=True)
    for f in fonts:
        target = dest / f["file"]
        if target.exists() and sha(target) == f["sha256"]:
            print(f"  ok      {f['file']}")
        else:
            tmp = download(f["url"], target)
            got = sha(tmp)
            if got != f["sha256"]:
                tmp.unlink()
                print(f"ERROR: {f['file']}: checksum {got} does not match the manifest; nothing installed for it")
                sys.exit(1)
            tmp.chmod(0o644)
            tmp.replace(target)
            print(f"  fetched {f['file']}")
        lic = dest / licence_name(f)
        if not lic.exists():
            tmp = download(f["licenseUrl"], lic)
            tmp.chmod(0o644)
            tmp.replace(lic)
    if shutil.which("fc-cache"):
        subprocess.run(["fc-cache", "-f", str(dest)], check=False)
    print(f"  ✓ fonts installed in {dest}")


if __name__ == "__main__":
    main(sys.argv)
