# Building Teretisma

The supported continuous-update pipeline is Python/FontForge based and does not require the legacy Ruby font database.

## Requirements

On Ubuntu 24.04:

```sh
sudo apt-get update
sudo apt-get install fontforge lcdf-typetools texlive-xetex texlive-font-utils texlive-latex-extra
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r scripts/automation/requirements.txt
```

Run commands from the repository root. The Python dependency versions are pinned. FontForge and LCDF typetools must be on `PATH`. The missing legacy TS3 encoding is vendored from CTAN Fontools with its own GPL license.

## Rebuild the pinned version

```sh
bash scripts/automation/run.sh
```

This verifies the pinned downloads, rebuilds the OpenType families, normalises their installation names and license metadata, regenerates TeX fonts/metrics, refreshes every release archive, checks shaping and coverage, and compiles modern and legacy TeX smoke documents. Logs and release assets are written to `build/`. `FONTFORGE` and `PYTHON` can select alternate executables.

## Update to the latest tracked upstream inputs

```sh
python scripts/automation/upstream.py
# Review upstream.lock.json and the source/license changes.
bash scripts/automation/run.sh
```

The scheduled workflow performs this daily and proposes a validated patch update. `--commit <full-sha>` selects an explicit Google Fonts revision; `--locked` reproduces the current lock and refuses checksum mismatches. Variable Sans/Serif fonts are instantiated at `wdth=87.5` and `wght=400/700`, including separate italics. All nine symbol weights are refreshed. Source/axis/license changes that do not match the configured assumptions stop the update for review.

The CSV selects the donor for each codepoint. Manual glyphs and hand-positioned composite recipes are preserved from the Teretisma masters, rather than guessed from upstream geometry. New upstream Unicode characters are included; a missing required donor glyph must already exist in the master or the build fails. Retentions and composition counts appear in `build/build-report.json`.

## Publish a stable version

After reviewing the candidate, set `VERSION`, build and validate it, update `RELEASE_NOTES.md`, and commit all generated fonts and packages. Then:

```sh
git tag -a "v$(cat VERSION)" -m "Teretisma $(cat VERSION)"
git push origin HEAD:main --follow-tags
```

The release workflow validates the tag and packages the committed binaries. It can also be dispatched manually for an existing tag. Download the current stable version from the repository's `/releases/latest` page. A stable release is never advanced by the daily update job.

## Legacy build scripts

The older Ruby implementation remains available for historical reference. Its font database and PDF-generation dependencies are not needed by the supported pipeline. Do not use it to publish releases; it does not perform the continuous pipeline's source, licensing, or archive checks.
