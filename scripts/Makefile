NEW_FONT_NAME = Teretisma
NEW_FONT_NAME_FILES = Teretisma


new-font-set: config/chars.csv
	@echo "Erzeuge neue Fonts aus Char-Config"
	ruby -e 'require "./lib/font_manager.rb"; FontManager.create_new_fonts(new_font_name: "$(NEW_FONT_NAME)", base_font_regex: /$(NEW_FONT_NAME_FILES)-.*-Manual/)'
	ruby -e 'require "./lib/font_manager.rb"; FontManager.create_math_font(new_font_name: "$(NEW_FONT_NAME)")'


render-pdf:
	@mkdir -p pdf-output/fonts/
	@cp torture-document/*.* pdf-output/
	@cp output/$(NEW_FONT_NAME_FILES)-*.otf pdf-output/fonts/
	sed 's/___FONT_PATH___/fonts\//g;s/___REGULAR_SERIF_FONT___/$(NEW_FONT_NAME_FILES)-Serif-Regular.otf/g;s/___BOLD_SERIF_FONT___/$(NEW_FONT_NAME_FILES)-Serif-Bold.otf/g;s/___ITALIC_SERIF_FONT___/$(NEW_FONT_NAME_FILES)-Serif-Italic.otf/g;s/___BOLD_ITALIC_SERIF_FONT___/$(NEW_FONT_NAME_FILES)-Serif-Bold-Italic.otf/g;s/___REGULAR_SANS_FONT___/$(NEW_FONT_NAME_FILES)-Sans-Regular.otf/g;s/___BOLD_SANS_FONT___/$(NEW_FONT_NAME_FILES)-Sans-Bold.otf/g;s/___ITALIC_SANS_FONT___/$(NEW_FONT_NAME_FILES)-Sans-Italic.otf/g;s/___BOLD_ITALIC_SANS_FONT___/$(NEW_FONT_NAME_FILES)-Sans-Bold-Italic.otf/g;' pdf-output/document.tex.template > pdf-output/document.tex
	cd pdf-output && xelatex document && xelatex document && xelatex document
