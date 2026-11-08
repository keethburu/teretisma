#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
cd "$(dirname "$0")/../.."
ROOT="$(pwd)"
mkdir -p build/smoke
sed "s|@FONT_PATH@|${ROOT}/fonts/|g" tests/modern.tex > build/smoke/modern.tex
xelatex -interaction=nonstopmode -halt-on-error -output-directory=build/smoke build/smoke/modern.tex > build/smoke/modern-build.log
TEXINPUTS="${ROOT}/fonts/TeX-fonts//:" \
TFMFONTS="${ROOT}/fonts/TeX-fonts//:" \
VFFONTS="${ROOT}/fonts/TeX-fonts//:" \
T1FONTS="${ROOT}/fonts/TeX-fonts//:" \
ENCFONTS="${ROOT}/fonts/TeX-fonts//:" \
TEXFONTMAPS="${ROOT}/fonts/TeX-fonts//:" \
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/smoke tests/legacy.tex > build/smoke/legacy-build.log
if grep -E 'Missing character:|Font shape .* undefined' build/smoke/modern.log build/smoke/legacy.log; then
  echo 'Font smoke test lost characters or styles' >&2
  exit 1
fi
