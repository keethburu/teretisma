# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('upstream',ROOT/'scripts/automation/upstream.py')
upstream=importlib.util.module_from_spec(spec);spec.loader.exec_module(upstream)

class UpstreamTests(unittest.TestCase):
    def test_exact_style_and_width_mapping(self):
        actual=dict(upstream.instances('notosans','NotoSans-Italic[wdth,wght].ttf'))
        self.assertEqual(actual,{
            'NotoSans-SemiCondensedItalic.ttf':{'wdth':87.5,'wght':400},
            'NotoSans-SemiCondensedBoldItalic.ttf':{'wdth':87.5,'wght':700}})
    def test_all_symbol_weights_preserved(self):
        actual=dict(upstream.instances('notosanssymbols','NotoSansSymbols[wght].ttf'))
        self.assertEqual(len(actual),9)
        self.assertEqual(actual['NotoSansSymbols-Light.ttf'],{'wght':300})
        self.assertEqual(actual['NotoSansSymbols-SemiBold.ttf'],{'wght':600})
    def test_unsafe_revision_rejected_before_network(self):
        with patch.object(upstream,'fetch') as fetch:
            with self.assertRaises(ValueError):upstream.update('../main')
            fetch.assert_not_called()
    def test_codepoint_recipes_match_literal_characters(self):
        import csv
        with (ROOT/'scripts/config/chars.csv').open() as source:
            for row in csv.DictReader(source,delimiter=';'):
                if len(row['char'])==1:
                    self.assertEqual(ord(row['char']),int(row['codepoint'],16))

if __name__=='__main__':unittest.main()
