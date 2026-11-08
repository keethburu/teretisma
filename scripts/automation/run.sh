#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
cd "$(dirname "$0")/../.."
PYTHON="${PYTHON:-python3}"
FONTFORGE="${FONTFORGE:-fontforge}"
mkdir -p build
"$PYTHON" scripts/automation/upstream.py --locked
"$FONTFORGE" -lang=py -script "$(pwd)/scripts/automation/build_fonts.py" > build/fontforge.log 2>&1
"$PYTHON" scripts/automation/metadata.py
"$PYTHON" scripts/automation/validate.py
"$PYTHON" scripts/automation/tex.py
"$PYTHON" scripts/automation/package.py
"$PYTHON" scripts/automation/validate.py --archives
bash scripts/automation/smoke.sh
