import fontforge
import sys

source_font = fontforge.open(sys.argv[1])
    
target_font = fontforge.open(sys.argv[2])
    
target_font.familyname = sys.argv[3]
target_font.fontname = sys.argv[3]
target_font.fullname = sys.argv[3]

target_glyph = int(sys.argv[4].strip().replace("uni",""),16)
base_source_glyph = int(sys.argv[5].strip().replace("uni",""),16)


target_font.selection.select(("more",None),target_glyph) 


source_font.selection.select(("more",None),base_source_glyph)
source_font.copy()
target_font.paste()

for i in sys.argv[6:]:
    source_font.selection.select(int(i.strip().replace("uni",""),16))
    source_font.copy()
    target_font.pasteInto()

target_font.generate(sys.argv[3] + ".otf") 
