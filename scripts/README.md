# Teretisma Font


## Installation

### Requirements

Required are the essential build tools, ruby, fontforge and texlive


sudo apt install build-essential ruby fontforge texlive-xetex texlive-lang-greek texlive-lang-german texlive-humanities texlive-math-extra

build-essential -> Make
fontforge -> automatic fontediting
texlive -> rendering of the example document

necessary libraries for ruby

gem install nokogiri
gem install pdfkit
gem install active_record


## Usage

### Creation of new fonts

1. place source font for glyphs in source_fonts
2. in config/chars.csv define the fonts used for the glyph for serif and sans serif versions (regular, bold, italic, bold italic)
3. make new-font-set
4. the new fonts are placed in output/

### Creation of test document with the new fonts

1. make render-pdf
2. the new document is placed in pdf-output/document.pdf

