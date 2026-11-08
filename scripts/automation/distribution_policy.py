# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject excluded proprietary-font components, including nested distributions."""
from pathlib import Path
import io
import re
import zipfile

EXCLUDED=re.compile(rb'minion[ _-]*math|mmath(?:deg|edg)|typoma',re.I)

def check_payload(name,data):
    if EXCLUDED.search(name.encode('utf8')):
        raise ValueError(f'Excluded proprietary-font component: {name}')
    if name.endswith('.zip'):
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            for item in archive.infolist():
                if not item.is_dir():check_payload(name+'!'+item.filename,archive.read(item))
    elif EXCLUDED.search(data):
        raise ValueError(f'Excluded proprietary-font reference in {name}')

def check_tree(root):
    for path in sorted(Path(root).rglob('*')):
        if path.is_file():check_payload(str(path.relative_to(root)),path.read_bytes())
