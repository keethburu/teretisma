PYTHON ?= python3
FONTFORGE ?= fontforge
.PHONY: new-font-set render-pdf

new-font-set:
	cd .. && PYTHON="$(PYTHON)" FONTFORGE="$(FONTFORGE)" bash scripts/automation/run.sh

render-pdf:
	$(PYTHON) automation/specimen.py
