# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
import io
from pathlib import Path
import unittest
import zipfile
path=Path(__file__).resolve().parents[1]/'scripts/automation/distribution_policy.py'
spec=importlib.util.spec_from_file_location('policy',path)
policy=importlib.util.module_from_spec(spec);spec.loader.exec_module(policy)

class DistributionPolicyTests(unittest.TestCase):
    def test_forbidden_component_path(self):
        with self.assertRaises(ValueError):policy.check_payload('mmathdeg/file.tfm',b'')
    def test_hidden_binary_font_reference(self):
        with self.assertRaises(ValueError):policy.check_payload('innocent.vf',b'\x00\x00MinionMath-Medium\x00')
    def test_nested_zip_reference(self):
        inner=io.BytesIO()
        with zipfile.ZipFile(inner,'w') as z:z.writestr('regular.pl',b'(FAMILY TEX-MINIONMATH)')
        outer=io.BytesIO()
        with zipfile.ZipFile(outer,'w') as z:z.writestr('support.zip',inner.getvalue())
        with self.assertRaises(ValueError):policy.check_payload('fonts.zip',outer.getvalue())
    def test_open_font_data(self):policy.check_payload('Teretisma.tfm',b'Teretisma Serif')
