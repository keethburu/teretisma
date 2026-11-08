#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
cd "$(dirname "$0")/../.."
PYTHON="${PYTHON:-python3}"
FONTFORGE="${FONTFORGE:-fontforge}"
mkdir -p build
"$PYTHON" scripts/automation/upstream.py --locked
# FontForge embeds the system Python; hostedtoolcache's libpython must not leak in.
if ! env -u LD_LIBRARY_PATH -u PYTHONHOME -u PYTHONPATH "$FONTFORGE" -lang=py -script "$(pwd)/scripts/automation/build_fonts.py" > build/fontforge.log 2>&1; then
  cat build/fontforge.log >&2
  exit 1
fi
"$PYTHON" scripts/automation/metadata.py
"$PYTHON" scripts/automation/validate.py
"$PYTHON" scripts/automation/tex.py
"$PYTHON" scripts/automation/package.py
"$PYTHON" scripts/automation/validate.py --archives
bash scripts/automation/smoke.sh
