#!/usr/bin/env python3
"""Pin Google Fonts inputs and produce the static instances used by Teretisma.
SPDX-License-Identifier: GPL-3.0-or-later
"""
import argparse
from datetime import datetime
import hashlib
import io
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
from urllib.parse import quote
from urllib.request import urlopen

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'scripts/source_fonts'
LOCK = ROOT / 'upstream.lock.json'
FAMILIES = {
 'notosans': ['NotoSans[wdth,wght].ttf', 'NotoSans-Italic[wdth,wght].ttf'],
 'notoserif': ['NotoSerif[wdth,wght].ttf', 'NotoSerif-Italic[wdth,wght].ttf'],
 'notosanssymbols': ['NotoSansSymbols[wght].ttf'],
 'notosanssymbols2': ['NotoSansSymbols2-Regular.ttf'],
 'notosansmath': ['NotoSansMath-Regular.ttf'],
}
WEIGHTS = {'Thin':100,'ExtraLight':200,'Light':300,'Regular':400,'Medium':500,
           'SemiBold':600,'Bold':700,'ExtraBold':800,'Black':900}

def sha(data):
    return hashlib.sha256(data).hexdigest()

def fetch(commit, path):
    url = f'https://raw.githubusercontent.com/google/fonts/{commit}/{quote(path, safe="/")}'
    with urlopen(url, timeout=90) as response:
        return response.read()

def latest_commit():
    line = subprocess.check_output(['git','ls-remote','https://github.com/google/fonts.git',
                                    'refs/heads/main'], text=True).strip()
    value = line.split()[0]
    if not re.fullmatch('[0-9a-f]{40}', value):
        raise ValueError('Invalid upstream commit')
    return value

def instances(family, filename):
    if family in ('notosans', 'notoserif'):
        prefix = 'NotoSans' if family == 'notosans' else 'NotoSerif'
        italic = 'Italic' in filename
        for weight, number in [('Regular',400),('Bold',700)]:
            suffix = ('' if weight == 'Regular' else weight) + ('Italic' if italic else '')
            yield f'{prefix}-SemiCondensed{suffix}.ttf', {'wdth':87.5,'wght':number}
    elif family == 'notosanssymbols':
        for weight, number in WEIGHTS.items():
            yield f'NotoSansSymbols-{weight}.ttf', {'wght':number}
    else:
        yield filename, {}

def update(commit=None, locked=False):
    previous = json.loads(LOCK.read_text()) if LOCK.exists() else None
    if locked:
        if not previous or not previous.get('commit'):
            raise ValueError('No pinned upstream; run update first')
        commit = previous['commit']
    commit = commit or latest_commit()
    if not re.fullmatch('[0-9a-f]{40}',commit):
        raise ValueError('Expected a full upstream commit SHA')
    with urlopen(f'https://api.github.com/repos/google/fonts/commits/{commit}', timeout=60) as response:
        commit_data=json.load(response)
    source_epoch=int(datetime.fromisoformat(commit_data['commit']['committer']['date'].replace('Z','+00:00')).timestamp())
    record = {'source_date_epoch':source_epoch,'repository':'https://github.com/google/fonts','commit':commit,
              'files':{},'instances':{}}
    # Stage all downloads and instances before replacing any input.
    with tempfile.TemporaryDirectory() as temp:
        stage = Path(temp)
        for family, names in FAMILIES.items():
            license_path = f'ofl/{family}/OFL.txt'
            license_data = fetch(commit,license_path)
            if b'SIL OPEN FONT LICENSE' not in license_data:
                raise ValueError(f'Unexpected license for {family}; review required')
            record['files'][license_path] = sha(license_data)
            (stage / f'{family}-OFL.txt').write_bytes(license_data)
            for name in names:
                path = f'ofl/{family}/{name}'
                data = fetch(commit,path)
                record['files'][path] = sha(data)
                for target, axes in instances(family,name):
                    font = TTFont(io.BytesIO(data), recalcTimestamp=False,
                                  cfg={'fontTools.ttLib.tables.otBase:USE_HARFBUZZ_REPACKER':False})
                    if axes:
                        available = {a.axisTag:(a.minValue,a.maxValue) for a in font['fvar'].axes}
                        if any(k not in available or not available[k][0]<=v<=available[k][1]
                               for k,v in axes.items()):
                            raise ValueError(f'Unsupported axes for {path}: {axes}')
                        font = instantiateVariableFont(font, axes, inplace=True)
                    font.recalcTimestamp = False
                    font.save(stage / target)
                    record['instances'][target] = {'source':path,'axes':axes,
                                                   'sha256':sha((stage/target).read_bytes())}
        if not locked and previous and record['files']==previous.get('files'):
            print('No changes to the tracked Google Fonts families')
            return previous
        if locked and record != previous:
            raise ValueError('Pinned input checksums differ; no sources replaced: '+
                             ', '.join(k for k in record if record[k]!=previous.get(k)))
        SOURCE.mkdir(exist_ok=True)
        licenses = ROOT/'licenses/upstream'
        licenses.mkdir(parents=True,exist_ok=True)
        for file in stage.iterdir():
            dest = licenses/file.name if file.name.endswith('-OFL.txt') else SOURCE/file.name
            dest.write_bytes(file.read_bytes())
        LOCK.write_text(json.dumps(record,indent=2,sort_keys=True)+'\n')
    print(f'Pinned {len(record["instances"])} inputs to google/fonts@{commit}')
    return record

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--commit')
    parser.add_argument('--locked',action='store_true',help='Reproduce and verify the recorded pin')
    args = parser.parse_args()
    update(args.commit,args.locked)
