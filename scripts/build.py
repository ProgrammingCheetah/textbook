#!/usr/bin/env python3
"""Compile a book with the bundled fonts and the textbook package.

Usage: scripts/build.py path/to/main.typ [out.pdf]

Works with the `typst` Python package (pip install typst), so it runs
anywhere Python does, including Claude's cloud workspace. Books import the
template with a path relative to the repo root ("/src/lib.typ") when they
live inside this repo, or as "@local/textbook:0.1.0" after scripts/install.sh.
"""
import sys, pathlib, typst

ROOT = pathlib.Path(__file__).resolve().parent.parent

def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    src = pathlib.Path(sys.argv[1]).resolve()
    out = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else src.with_suffix(".pdf")
    root = ROOT if ROOT in src.parents else src.parent
    # Expose this repo as @local/textbook:<version> without installing it.
    version = next(l.split('"')[1] for l in (ROOT / "typst.toml").read_text().splitlines()
                   if l.startswith("version"))
    pkgs = ROOT / ".packages"
    link = pkgs / "local" / "textbook" / version
    if not link.exists():
        link.parent.mkdir(parents=True, exist_ok=True)
        link.symlink_to(ROOT, target_is_directory=True)
    try:
        typst.compile(str(src), output=str(out), root=str(root),
                      font_paths=[str(ROOT / "fonts")], package_path=str(pkgs))
    except typst.TypstError as e:
        print(e.diagnostic or e.message, file=sys.stderr)
        sys.exit(1)
    print(out)

if __name__ == "__main__":
    main()
