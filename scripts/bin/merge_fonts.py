import fontforge
import sys

with open(sys.argv[1]) as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [int(x.strip().replace("uni",""),16) for x in content]


source_font = fontforge.open(sys.argv[2])
[source_font.selection.select(("more",None),x) for x in content]
if content:
    print("Copy")
    source_font.copy()
    print("Copy")

target_font = fontforge.open(sys.argv[3])
[target_font.selection.select(("more",None),x) for x in content]
if content:
    print("Paste")
    target_font.paste()
    print("Paste")

target_font.familyname = sys.argv[5]
target_font.fontname = sys.argv[4]
target_font.fullname = sys.argv[4]
target_font.generate(sys.argv[4] + ".otf")
