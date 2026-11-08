#!/usr/bin/env python3
"""Render the unbranded Teretisma specimen. SPDX-License-Identifier: GPL-3.0-or-later"""
from pathlib import Path
import shutil
import subprocess
ROOT=Path(__file__).resolve().parents[2]
out=ROOT/'scripts/pdf-output';out.mkdir(exist_ok=True)
(out/'fonts').mkdir(exist_ok=True)
for path in (ROOT/'fonts').glob('Teretisma-*.otf'):shutil.copy2(path,out/'fonts'/path.name)
source=ROOT/'scripts/torture-document'
shutil.copy2(source/'teretisma.sty',out/'teretisma.sty')
text=(source/'document.tex.template').read_text().replace('___FONT_PATH___','fonts/')
styles={'REGULAR':'Regular','BOLD':'Bold','ITALIC':'Italic','BOLD_ITALIC':'Bold-Italic'}
for family in ['SERIF','SANS']:
    for style,filename in styles.items():
        text=text.replace(f'___{style}_{family}_FONT___',f'Teretisma-{family.title()}-{filename}.otf')
(out/'document.tex').write_text(text)
subprocess.run(['xelatex','-interaction=nonstopmode','-halt-on-error','document.tex'],cwd=out,check=True)
