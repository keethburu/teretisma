#!/usr/bin/env python3
"""Create repeatable release assets and refresh the in-repository font ZIPs.
SPDX-License-Identifier: GPL-3.0-or-later
"""
import hashlib
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]

def zip_files(path,items):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as z:
        for name,data in sorted(items):
            info=zipfile.ZipInfo(name,(2020,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
            info.external_attr=0o644<<16;z.writestr(info,data)

def specimen():
    from fontTools.ttLib import TTFont
    from fontTools.pens.svgPathPen import SVGPathPen
    parts=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1100 540" role="img" aria-label="Teretisma Serif and Sans specimen">',
           '<rect width="1100" height="540" fill="#faf8f2"/>']
    for family,y in [('Serif',120),('Sans',350)]:
        f=TTFont(ROOT/f'fonts/Teretisma-{family}-Regular.otf');gs=f.getGlyphSet();cmap=f.getBestCmap()
        scale=52/f['head'].unitsPerEm
        for text,baseline in [(f'Teretisma {family}',y),('Latin · Ελληνικά · Кириллица',y+80)]:
            x=50
            for char in text:
                glyph=cmap[ord(char)];pen=SVGPathPen(gs);gs[glyph].draw(pen)
                parts.append(f'<path d="{pen.getCommands()}" transform="translate({x},{baseline}) scale({scale},-{scale})" fill="#202b33"/>')
                x+=f['hmtx'][glyph][0]*scale
    parts.append('</svg>')
    (ROOT/'assets/images/font-preview.svg').write_text('\n'.join(parts)+'\n')

def package():
    specimen()
    for installed in (ROOT/'fonts/TeX-fonts').rglob('*.otf'):
        current=ROOT/'fonts'/installed.name
        if current.exists():installed.write_bytes(current.read_bytes())
    modern=[(p.name,p.read_bytes()) for p in (ROOT/'fonts').glob('*.otf')]
    common=[('OFL.txt',(ROOT/'LICENSE').read_bytes()),('VERSION',(ROOT/'VERSION').read_bytes()),
            ('upstream.lock.json',(ROOT/'upstream.lock.json').read_bytes())]
    modern+=common
    # Preserve the historic download URL while replacing all font payloads.
    zip_files(ROOT/'fonts/teretisma-sans_serif_icons.zip',modern)
    combined=[]
    for name in ['TeretismaSans','TeretismaSerif','mmathdeg']:
        base=ROOT/'fonts/TeX-fonts'/name
        items=[(str(p.relative_to(base)),p.read_bytes()) for p in base.rglob('*') if p.is_file()]
        zip_files(base.with_suffix('.zip'),items)
        if name!='mmathdeg':combined+=items
    # A merged TDS tree; repeated OFL files must agree.
    unique={}
    for name,data in combined:
        if name in unique and unique[name]!=data:raise ValueError(f'Conflicting TDS entry {name}')
        unique[name]=data
    zip_files(ROOT/'fonts/TeX-fonts/Teretisma_Sans_Serif_Font_LaTeX.zip',list(unique.items()))
    release=ROOT/'build/release';release.mkdir(parents=True,exist_ok=True)
    zip_files(release/'teretisma-fonts.zip',modern)
    tex=[(str(p.relative_to(ROOT/'fonts/TeX-fonts')),p.read_bytes())
         for p in (ROOT/'fonts/TeX-fonts').rglob('*') if p.is_file()]
    zip_files(release/'teretisma-tex.zip',tex+common)
    (release/'OFL.txt').write_bytes((ROOT/'LICENSE').read_bytes())
    sums=[]
    for p in sorted(release.iterdir()):
        if p.name!='SHA256SUMS':sums.append(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}')
    (release/'SHA256SUMS').write_text('\n'.join(sums)+'\n')
    print('Built release assets in build/release')
if __name__=='__main__':package()
