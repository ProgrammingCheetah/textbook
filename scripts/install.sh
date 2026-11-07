#!/usr/bin/env sh
# Install this repo as the local Typst package @local/textbook:<version>,
# so any book on this machine can `#import "@local/textbook:0.1.0": *`
# and `typst init @local/textbook:0.1.0 my-book` works.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' "$ROOT/typst.toml")"
case "$(uname -s)" in
  Darwin) DATA="$HOME/Library/Application Support" ;;
  *)      DATA="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
esac
DEST="$DATA/typst/packages/local/textbook/$VERSION"
mkdir -p "$(dirname "$DEST")"
ln -sfn "$ROOT" "$DEST"
echo "Linked $DEST -> $ROOT"
echo "Compile with: typst compile --font-path \"$ROOT/fonts\" main.typ"
