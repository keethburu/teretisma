#!/usr/bin/env python3
"""Normalise release metadata and preserve all font license notices.
SPDX-License-Identifier: GPL-3.0-or-later
"""
from pathlib import Path
import json
import os
from fontTools.ttLib import TTFont

ROOT=Path(__file__).resolve().parents[2]
LICENSE_TEXT='This Font Software is licensed under the SIL Open Font License, Version 1.1.'

def main():
    version=(ROOT/'VERSION').read_text().strip()
    source=(ROOT/'LICENSE').read_text()
    header=source[:source.index('This Font Software is licensed')].strip()
    lines=set(header.splitlines())
    for path in (ROOT/'licenses/upstream').glob('*-OFL.txt'):
        text=path.read_text()
        for line in text.splitlines():
            if line.startswith('Copyright'):lines.add(line)
    notices='\n'.join(sorted(line for line in lines if line))
    license_data=notices+'\n\n'+source[source.index('This Font Software is licensed'):]
    for path in [ROOT/'LICENSE',ROOT/'fonts/LICENSE',ROOT/'scripts/source_fonts/LICENSE']:
        path.write_text(license_data)
    lock=json.loads((ROOT/'upstream.lock.json').read_text())
    epoch=int(lock['source_date_epoch'])
    for path in (ROOT/'fonts').glob('*.otf'):
        font=TTFont(path,recalcTimestamp=False)
        stem=path.stem
        family= ('Teretisma Sans Math' if 'Math' in stem else 'Teretisma Icons' if 'Icons' in stem
                 else 'Teretisma Serif' if '-Serif-' in stem else 'Teretisma Sans')
        style='Bold Italic' if 'Bold-Italic' in stem else 'Bold' if 'Bold' in stem else 'Italic' if 'Italic' in stem else 'Regular'
        # Explicitly write every platform's menu/typographic/WWS names.
        values={0:notices,1:family,2:style,3:f'{version};TERE;{stem};{lock["commit"][:12]}',
                4:family+' '+style,5:'Version '+version,6:stem,8:'Teretisma contributors',
                11:'https://github.com/keethburu/teretisma',13:LICENSE_TEXT,
                14:'https://openfontlicense.org/',16:family,17:style,18:family+' '+style,
                21:family,22:style,25:stem}
        font['name'].names=[n for n in font['name'].names if n.nameID not in values]
        for name_id,value in values.items():
            font['name'].setName(value,name_id,3,1,0x409)
        if 'FFTM' in font:del font['FFTM']  # Drop FontForge's wall-clock timestamp table.
        font['OS/2'].achVendID='TERE';font['OS/2'].fsType=0
        font['head'].fontRevision=float('.'.join(version.split('.')[:2]))
        font['head'].created=font['head'].modified=epoch+2082844800
        if 'CFF ' in font:
            cff=font['CFF '].cff;cff.fontNames=[stem]
            top=cff.topDictIndex[0];top.FamilyName=family;top.FullName=family+' '+style
            top.Notice=notices;top.version=version
        font.save(path)
    print('Teretisma installation names, version, provenance, and OFL metadata verified for output')

if __name__=='__main__':main()
