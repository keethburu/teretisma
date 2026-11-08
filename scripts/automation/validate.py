#!/usr/bin/env python3
"""Validate installation names, coverage, shaping and distribution consistency.
SPDX-License-Identifier: GPL-3.0-or-later
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import zipfile
from fontTools.ttLib import TTFont
import uharfbuzz as hb

ROOT=Path(__file__).resolve().parents[2]
OLD=re.compile(r'gruyter|degryuter|gruyto|dgruyter',re.I)
VISIBLE_IDS={1,2,3,4,6,16,17,18,21,22,25}

def inspect_font(data,name):
    font=TTFont(io.BytesIO(data),recalcTimestamp=False)
    for n in font['name'].names:
        if n.nameID in VISIBLE_IDS and OLD.search(n.toUnicode()):
            raise ValueError(f'{name}: old installation name {n.toUnicode()}')
    expected_version=(ROOT/'VERSION').read_text().strip()
    if font['name'].getDebugName(5)!='Version '+expected_version:
        raise ValueError(f'{name}: font version does not match VERSION')
    family=font['name'].getDebugName(16) or font['name'].getDebugName(1)
    if not family.startswith('Teretisma '):raise ValueError(f'{name}: unexpected family {family}')
    if 'SIL Open Font License' not in (font['name'].getDebugName(13) or ''):
        raise ValueError(f'{name}: no embedded font license')
    if font['OS/2'].fsType!=0:raise ValueError(f'{name}: embedding restrictions')
    if 'CFF ' in font:
        cff=font['CFF '].cff
        for value in [*cff.fontNames,cff.topDictIndex[0].FamilyName,cff.topDictIndex[0].FullName]:
            if OLD.search(value):raise ValueError(f'{name}: old CFF name')
    # Parse every table, not just the sfnt directory.
    for tag in font.keys():
        if tag!='GlyphOrder':font[tag]
    return font

def shaping(data,sample):
    face=hb.Face(data);font=hb.Font(face);hb.ot_font_set_funcs(font)
    b=hb.Buffer();b.add_str(sample);b.guess_segment_properties()
    hb.shape(font,b,{'liga':True,'kern':True})
    if any(i.codepoint==0 for i in b.glyph_infos):raise ValueError(f'Missing shaped glyph: {sample}')
    if not b.glyph_infos:raise ValueError('Empty shaping result')

def validate_fonts():
    paths=sorted((ROOT/'fonts').glob('*.otf'))
    if len(paths)!=10:raise ValueError(f'Expected 10 release fonts, got {len(paths)}')
    for path in paths:
        data=path.read_bytes();font=inspect_font(data,path.name);cmap=font.getBestCmap()
        if 'Icons' in path.name and not set(range(49,54))<=set(cmap):
            raise ValueError('The five icon codepoints must be preserved')
        if 'Math' not in path.name and 'Icons' not in path.name:
            master=ROOT/'scripts/source_fonts'/path.name.replace('.otf','.otf').replace('-Regular','-Manual-Regular').replace('-Bold','-Manual-Bold')
            if '-Italic' in path.name and 'Bold' not in path.name:
                master=ROOT/'scripts/source_fonts'/path.name.replace('-Italic','-Manual-Italic')
            expected=set(TTFont(master).getBestCmap())-{0,13,0xFFFE,0xFFFF}
            missing=expected-set(cmap)
            if missing:raise ValueError(f'{path.name}: lost {sorted(missing)[:15]}')
            for sample in ['Teretisma office affine 0123456789','ἄνθρωπος Ελληνικά','Кириллица русский','a\u0301 o\u0308']:
                shaping(data,sample)
            features={rec.FeatureTag for tag in ['GSUB','GPOS'] if tag in font
                      for rec in font[tag].table.FeatureList.FeatureRecord}
            if not {'liga','kern','smcp','onum','tnum'}<=features:
                raise ValueError(f'{path.name}: missing layout features {features}')
            for glyph,(width,_) in font['hmtx'].metrics.items():
                if width>font['head'].unitsPerEm*8:raise ValueError(f'{path.name}: invalid width for {glyph}: {width}')
        print(path.name, font['name'].getDebugName(1),len(cmap),'codepoints')
    return paths

def archives():
    count=0
    def inspect(data,path):
        nonlocal count
        z=zipfile.ZipFile(io.BytesIO(data));bad=z.testzip()
        if bad:raise ValueError(f'{path}: corrupt {bad}')
        count+=1
        for name in z.namelist():
            if OLD.search(name):raise ValueError(f'{path}: old archive path {name}')
            raw=z.read(name)
            if name.endswith('.zip'):inspect(raw,path+'/'+name)
            if name.endswith('.pfb'):
                # Visible Type 1 names live in the clear-text PFB header.
                for line in raw.decode('latin1').splitlines():
                    if any(k in line for k in ('/FontName','/FamilyName','/FullName')) and OLD.search(line):
                        raise ValueError(f'{path}: old Type 1 installation name')
            if name.endswith('.otf'):
                inspect_font(raw,name)
                release=ROOT/'fonts'/Path(name).name
                if release.exists() and raw!=release.read_bytes():
                    raise ValueError(f'{path}: stale bundled font {name}')
    for path in (ROOT/'fonts').rglob('*.zip'):inspect(path.read_bytes(),str(path))
    for family in ['Sans','Serif']:
        for path in (ROOT/f'fonts/TeX-fonts/Teretisma{family}').rglob('*.otf'):
            if path.read_bytes()!=(ROOT/'fonts'/path.name).read_bytes():raise ValueError(f'Stale {path}')
    print(count,'archives checked; all bundled OpenType fonts match current builds')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--archives',action='store_true');args=p.parse_args()
    validate_fonts()
    if args.archives:archives()
