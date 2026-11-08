#!/usr/bin/env python3
"""Rebuild TeX Type 1 fonts and metrics using the inherited autoinst recipes.
SPDX-License-Identifier: GPL-3.0-or-later
"""
from pathlib import Path
import shutil
import subprocess
import tempfile
import zipfile
ROOT=Path(__file__).resolve().parents[2]

def rebuild():
    for family in ['Sans','Serif']:
        package=ROOT/f'fonts/TeX-fonts/Teretisma{family}'
        recipe=next(package.rglob('*Installation.zip'))
        with tempfile.TemporaryDirectory() as temp:
            work=Path(temp)
            with zipfile.ZipFile(recipe) as z:
                # Never extract arbitrary paths from archives.
                for item in z.infolist():
                    if item.is_dir():continue
                    if Path(item.filename).name!=item.filename:raise ValueError(item.filename)
                    (work/item.filename).write_bytes(z.read(item))
            shutil.copy2(ROOT/'scripts/automation/vendor/fontools/fontools_ts3.enc',work/'fontools_ts3.enc')
            for font in (ROOT/'fonts').glob(f'Teretisma-{family}-*.otf'):
                if 'Math' not in font.name:shutil.copy2(font,work/font.name)
            log=ROOT/f'build/tex-{family.lower()}.log'
            with log.open('w') as output:
                # Execute the generator directly; avoid the old script's mmv/updmap side effects.
                subprocess.run(['perl','autoinst',
                    '-encoding=OT1,T1,TS1,LY1,QX,L7x,OT2,T2A,T2B,T2C,X2,T3,TS3,T4,T5,LGR,U,2BS,PUA,OML,OMS',
                    '-noswash','-notitling','-smallcaps','-noinferiors','-nosuperiors',
                    '-nofractions','-noornaments','-t1suffix','-target=.',
                    *[f'Teretisma-{family}-{s}.otf' for s in ['Regular','Italic','Bold','Bold-Italic']]],
                    cwd=work,stdout=output,stderr=subprocess.STDOUT,check=True)
            if '[ERROR]' in log.read_text():
                raise ValueError(f'autoinst reported errors despite its exit status; see {log}')
            # Retain documented package macros, replace every generated metric/outline/encoding/map.
            mappings={'.tfm':f'fonts/tfm/google/Teretisma{family}',
                      '.vf':f'fonts/vf/google/Teretisma{family}',
                      '.pfb':f'fonts/type1/google/Teretisma{family}',
                      '.enc':f'fonts/enc/dvips/Teretisma{family}',
                      '.map':'fonts/map/dvips',
                      '.fd':f'tex/latex/google/Teretisma{family}'}
            for ext,folder in mappings.items():
                dest=package/folder;dest.mkdir(parents=True,exist_ok=True)
                # Remove the typo-named inherited encoding directory as well.
                if ext=='.enc':
                    for old in (package/'fonts/enc/dvips').iterdir():
                        if old.is_dir():shutil.rmtree(old)
                    dest.mkdir(parents=True,exist_ok=True)
                for old in dest.glob('*'+ext):old.unlink()
                generated=list(work.rglob('*'+ext))
                if not generated:raise ValueError(f'No {ext} output for {family}; see {log}')
                for item in generated:
                    name=item.name.replace('L7X','L7x')
                    if ext in ('.fd','.enc','.map'):
                        text=item.read_text().replace('L7X','L7x') if ext=='.fd' else item.read_text()
                        (dest/name).write_text('\n'.join(line.rstrip() for line in text.splitlines())+'\n')
                    else:shutil.copy2(item,dest/name)
            otf_dir=package/f'fonts/opentype/google/Teretisma{family}'
            for font in (ROOT/'fonts').glob(f'Teretisma-{family}-*.otf'):
                if 'Math' not in font.name:shutil.copy2(font,otf_dir/font.name)
            for installed in package.rglob('*.otf'):
                current=ROOT/'fonts'/installed.name
                if current.exists():shutil.copy2(current,installed)
            (package/'OFL.txt').write_bytes((ROOT/'LICENSE').read_bytes())
            print(f'Rebuilt TeX package Teretisma{family}')
if __name__=='__main__':rebuild()
