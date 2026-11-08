#!/usr/bin/env python3
"""Run with fontforge -lang=py -script. SPDX-License-Identifier: GPL-3.0-or-later"""
import csv
import json
import os
from pathlib import Path
import sys
import fontforge

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'scripts/source_fonts'
OUT=ROOT/'fonts'
version=(ROOT/'VERSION').read_text().strip()
rows=list(csv.DictReader((ROOT/'scripts/config/chars.csv').open(),delimiter=';'))
report={}

def copy_glyphs(donor,target,codepoints):
    donor.selection.none(); target.selection.none()
    for cp in codepoints:
        donor.selection.select(('more','unicode'),cp)
        target.selection.select(('more','unicode'),cp)
    if codepoints:
        donor.copy(); target.paste()

def finish(font,name,family,style,path):
    font.fontname=name; font.familyname=family; font.fullname=family+' '+style
    font.weight='Bold' if 'Bold' in style else 'Regular'
    font.version=version
    font.os2_weight=700 if 'Bold' in style else 400
    font.os2_width=4 if 'Math' not in family and 'Icons' not in family else 5
    font.os2_vendor='TERE'
    font.generate(str(path),flags=('opentype','round'))

for family in ('Sans','Serif'):
    for style in ('Regular','Italic','Bold','Bold-Italic'):
        column=(family+'-'+style).lower()
        filename=f'Teretisma-{family}-{style}.otf'
        target=fontforge.open(str(SOURCE/f'Teretisma-{family}-Manual-{style}.otf'))
        target.encoding="UnicodeFull"
        target.em=1000
        specs={int(row['codepoint'],16):row[column] for row in rows if row[column]}
        base=f'Noto{family}-SemiCondensed'+('' if style=='Regular' else style.replace('-',''))+'.ttf'
        donors={}
        def donor(name):
            if name not in donors:
                font=fontforge.open(str(SOURCE/name));font.encoding='UnicodeFull';font.em=target.em;donors[name]=font
            return donors[name]
        primary=donor(base)
        # Preserve custom glyphs and hand-positioned compositions in the manual master.
        protected={cp for cp,spec in specs.items() if '(' in spec or not spec.startswith('Noto')}
        cp_primary={g.unicode for g in primary.glyphs() if g.unicode>=0}
        direct={cp:spec for cp,spec in specs.items() if '(' not in spec}
        for cp in cp_primary:
            if cp not in protected and cp not in direct:direct[cp]=base
        groups={}
        retained=[]
        for cp,spec in direct.items():
            if spec.startswith('Teretisma-'):continue
            font=donor(spec)
            if cp not in font:
                if cp in target:
                    retained.append(f'U+{cp:04X} from manual master ({spec} lacks it)')
                    continue
                if cp<32 or cp in (0xFFFE,0xFFFF):continue
                raise ValueError(f'{filename}: required U+{cp:04X} missing from {spec} and master')
            groups.setdefault(spec,[]).append(cp)
        for spec,cps in sorted(groups.items()):copy_glyphs(donor(spec),target,sorted(cps))
        target.selection.all()
        target.transform((.95,0,0,.95,0,0))
        target.round()
        finish(target,filename[:-4],f'Teretisma {family}',style.replace('-',' '),OUT/filename)
        report[filename]={'copied':sum(map(len,groups.values())),
                          'preserved_compositions':sum('(' in s for s in specs.values()),
                          'retained':retained}
        target.close()
        for f in donors.values():f.close()
math=fontforge.open(str(SOURCE/'NotoSansMath-Regular.ttf'))
math.em=1000;math.selection.all();math.transform((.95,0,0,.95,0,0));math.round()
finish(math,'Teretisma-Sans-Math-Regular','Teretisma Sans Math','Regular',OUT/'Teretisma-Sans-Math-Regular.otf')
math.close()
icons=fontforge.open(str(SOURCE/'Teretisma-Icons.sfd'))
# Font selection and typeset specimens require an ordinary word-space glyph.
if 32 not in icons:icons.createChar(32,'space').width=250
finish(icons,'Teretisma-Icons','Teretisma Icons','Regular',OUT/'Teretisma-Icons.otf')
icons.close()
(ROOT/'build').mkdir(exist_ok=True)
(ROOT/'build/build-report.json').write_text(json.dumps(report,indent=2)+'\n')
