# coding: utf-8

require 'pdfkit'
require 'nokogiri'
class PdfCreator
  include Singleton

  BLINDTEXT = "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ abcdefghijklmnopqrstuvwxyzäöüß 1234567890 Dies ist ein Typoblindtext. An ihm kann man sehen, ob alle Buchstaben da sind und wie sie aussehen. Manchmal benutzt man Worte wie Hamburgefonts, Rafgenduks oder Handgloves, um Schriften zu testen. Manchmal Sätze, die alle Buchstaben des Alphabets enthalten – man nennt diese Sätze »Pangrams«. Sehr bekannt ist dieser: The quick brown fox jumps over the lazy old dog. Oft werden in Typoblindtexte auch fremdsprachige Satzteile eingebaut (AVAIL® and Wefox™ are testing aussi la Kerning), um die Wirkung in anderen Sprachen zu testen. In Lateinisch sieht zum Beispiel fast jede Schrift gut aus. Quod erat demonstrandum. Seit 1975 fehlen in den meisten Testtexten die Zahlen, weswegen nach TypoGb. 204 § ab dem Jahr 2034 Zahlen in 86 der Texte zur Pflicht werden. Nichteinhaltung wird mit bis zu 245 € oder 368 $ bestraft. Genauso wichtig in sind mittlerweile auch Âçcèñtë, die in neueren Schriften aber fast immer enthalten sind. Ein wichtiges aber schwierig zu integrierendes Feld sind OpenType-Funktionalitäten. Je nach Software und Voreinstellungen können eingebaute Kapitälchen, Kerning oder Ligaturen (sehr pfiffig) nicht richtig dargestellt werden. Griechisches Lorem Ipsum: Λορεμ ιπσθμ δολορ σιτ αμετ, νοvθμ φαβελλασ πετεντιθμ vελ νε, ατ νισλ σονετ οπορτερε εθμ. Αλιι δοcτθσ μει ιδ, νο αθτεμ αθδιρε ιντερεσσετ μελ, δοcενδι cομμθνε οπορτεατ τε cθμ. Russisches Lorem Ipsum: Лорем ипсум долор сит амет, пер цлита поссит ех, ат мунере фабулас петентиум сит. Иус цу цибо саперет сцрипсерит, нец виси муциус лабитур ид. Ет хис нонумес нолуиссе дигниссим."


  TEX_HEADER = <<-END
\\documentclass[10pt,twocolumn]{report}
\\usepackage{geometry}
 \\geometry{
 a4paper,
 total={190mm,277mm},
 left=10mm,
 top=10mm,
 }
\\usepackage{fontspec}
\\setlength{\\parindent}{0pt}
\\pagestyle{empty}
\\begin{document}

\\newcommand{\\blindtext}{%
\\noindent{}aäb cde fgh ijk lmn oöp qrsß tuü vwx yz AÄBC DEF GHI JKL MNO ÖPQ RST UÜV WXYZ !"§ \\$\\%\\& /() =?* ' \\# \\symbol{"7E} ²³ @`´ ©«» ¼ \\{\\} €  - -- ---

  Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch
  Bayern. Zwölf Boxkämpfer jagen Viktor quer über den großen Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick
  den Jux bei Pforzheim. Polyfon zwitschernd aßen Mäxchens Vögel Rüben, Joghurt und Quark. ,,Fix, Schwyz!'' quäkt Jürgen blöd vom
  Paß. Victor jagt zwölf Boxkämpfer quer über den großen Sylter Deich. Falsches Üben von Xylophonmusik quält jeden größeren
  Zwerg. Heizölrückstoßabdämpfung.

%%  Ligaturen: ﬀ, ﬁ, ﬂ, ft, ﬃ, ﬄ, fk, fj, fh, fb, fz, ll, st, ch, ck, ct, th, tt, tz, kk, Qu, ſi, ſſ, ﬅ, ſch
%%
%%  Λορεμ ιπσθμ δολορ σιτ αμετ, νοvθμ φαβελλασ πετεντιθμ vελ νε, ατ νισλ σονετ οπορτερε εθμ. Αλιι δοcτθσ μει ιδ, νο αθτεμ αθδιρε ιντερεσσετ μελ, δοcενδι cομμθνε οπορτεατ τε cθμ.
%%
%%  Лорем ипсум долор сит амет, пер цлита поссит ех, ат мунере фабулас петентиум сит. Иус цу цибо саперет сцрипсерит, нец виси муциус лабитур ид. Ет хис нонумес нолуиссе дигниссим.
%%
%%  ÀÁÂ ÃÄÅ ÆÇÈ ÉÊË ÌÍÎ ÏÐÑ ÒÓÔ ÕÖ× ØÙÚ ÛÜÝ Þßà áâã äåæ çèé êëì íîï ðñò óôõ ö÷ø ùúû üýþ ÿ ĀāĂ ăĄą ĆćĈ ĉĊċ ČčĎ ďĐđ ĒēĔ ĕĖė ĘęĚ ěĜĝ ĞğĠ ġĢģ ĤĥĦ ħĨĩ ĪīĬ ĭĮį İıĲ ĳĴĵ Ķķĸ ĹĺĻ ļĽľ ĿŀŁ łŃń ŅņŇ ňŉŊ ŋŌō ŎŏŐ őŒœ ŔŕŖ ŗŘř ŚśŜ ŝŞş ŠšŢ ţŤť ŦŧŨ ũŪū ŬŭŮ ůŰű ŲųŴ ŵŶŷ ŸŹź ŻżŽ žſ ḀḁḂ ḃḄḅ ḆḇḈ ḉḊḋ ḌḍḎ ḏḐḑ ḒḓḔ ḕḖḗ ḘḙḚ ḛḜḝ ḞḟḠ ḡḢḣ ḤḥḦ ḧḨḩ ḪḫḬ ḭḮḯ ḰḱḲ ḳḴḵ ḶḷḸ ḹḺḻ ḼḽḾ ḿṀṁ ṂṃṄ ṅṆṇ ṈṉṊ ṋṌṍ ṎṏṐ ṑṒṓ ṔṕṖ ṗṘṙ ṚṛṜ ṝṞṟ ṠṡṢ ṣṤṥ ṦṧṨ ṩṪṫ ṬṭṮ ṯṰṱ ṲṳṴ ṵṶṷ ṸṹṺ ṻṼṽ Ṿṿ
%%
%%  SmallCaps: \\textsc{abcd efgh ijkl mnop qrst uvwx yzāă ąćĉċ čďđē ĕėęě ĝğġģ ĥħĩī ĭįi̇ı ĳĵķĸ ĺļľŀ łńņň ŉŋōŏ őœŕŗ řśŝş šţťŧ ũūŭů űųŵŷ ÿźżž ſƀɓƃ ƅɔƈɖ ɗƌƍǝ əɛƒɠ ɣƕɩɨ ƙƚƛɯ ɲƞɵơ ƣƥʀƨ ʃƪƫƭ ʈưʊʋ ƴƶʒƹ ƺƻƽƾ ƿǀǁǂ ǃǆǉǌ ǎǐǒ ǔǖǘǚ ǜǟǡ ǣǥǧǩ ǫǭǯǰ ǳǵǹǻ ǽǿḁḃ ḅḇḉḋ ḍḏḑḓ ḕḗḙḛ ḝḟḡḣ ḥḧḩḫ ḭḯḱḳ ḵḷḹḻ ḽḿṁṃ ṅṇṉṋ ṍṏṑṓ ṕṗṙṛ ṝṟṡṣ ṥṧṩṫ ṭṯṱṳ ṵṷṹṻ ṽṿ}
%%
%%  ƀƁƂ ƃƄƅ ƆƇƈ ƉƊƋ ƌƍƎ ƏƐƑ ƒƓƔ ƕƖƗ Ƙƙƚ ƛƜƝ ƞƟƠ ơƢƣ ƤƥƦ ƧƨƩ ƪƫƬ ƭƮƯ ưƱƲ ƳƴƵ ƶƷƸ ƹƺƻ Ƽƽƾ ƿǀǁ ǂǃǄ ǅǆǇ ǈǉǊ ǋǌǍ ǎǏǐ ǑǒǓ ǔǕǖ ǗǘǙ ǚǛǜ ǝǞǟ ǠǡǢ ǣǤǥ ǦǧǨ ǩǪǫ ǬǭǮ ǯǰǱ ǲǳǴ ǵǶǷ ǸǹǺ ǻǼǽ Ǿǿ
%%
%%  ἀἁἂ ἃἄἅ ἆἇἈ ἉἊἋ ἌἍἎ Ἇἐἑ ἒἓἔ ἕ἖἗ ἘἙἚ ἛἜἝ ἞἟ἠ ἡἢἣ ἤἥἦ ἧἨἩ ἪἫἬ ἭἮἯ ἰἱἲ ἳἴἵ ἶἷἸ ἹἺἻ ἼἽἾ Ἷὀὁ ὂὃὄ ὅ὆὇ ὈὉὊ ὋὌὍ ὎὏ὐ ὑὒὓ ὔὕὖ ὗ὘Ὑ ὚Ὓ὜ Ὕ὞Ὗ ὠὡὢ ὣὤὥ ὦὧὨ ὩὪὫ ὬὭὮ Ὧὰά ὲέὴ ήὶί ὸόὺ ύὼώ ὾὿
%%
%%  ͰͱͲ ͳʹ͵ Ͷͷ͸ ͹ͺͻ ͼͽ; Ϳ΀΁ ΂΃΄ ΅Ά· ΈΉΊ ΋Ό΍ ΎΏΐ ΑΒΓ ΔΕΖ ΗΘΙ ΚΛΜ ΝΞΟ ΠΡ΢ ΣΤΥ ΦΧΨ ΩΪΫ άέή ίΰα βγδ εζη θικ λμν ξοπ ρςσ τυφ χψω ϊϋό ύώϏ ϐϑϒ ϓϔϕ ϖϗϘ ϙϚϛ ϜϝϞ ϟϠϡ ϢϣϤ ϥϦϧ ϨϩϪ ϫϬϭ Ϯϯ
%%
  ⌀⌁⌂ ⌃⌄⌅⌆ ⌇⌈⌉⌊ ⌋⌌ ⌍⌎⌏⌐ ⌑⌒⌓ ⌔⌕⌖ ⌗⌘⌙ ⌚⌛⌜ ⌝⌞⌟ ⌠⌡⌢ ⌣⌤⌥ ⌦⌧⌨ 〈〉⌫ ⌬⌭⌮ ⌯⌰⌱ ⌲⌳⌴ ⌵⌶⌷ ⌸⌹⌺ ⌻⌼⌽ ⌾⌿⍀ ⍁⍂⍃ ⍄⍅⍆ ⍇⍈ ⍉⍊ ⍋⍌⍍ ⍎⍏⍐ ⍑⍒⍓ ⍔⍕⍖ ⍗⍘⍙ ⍚⍛⍜
  ⍝⍞⍟ ⍠⍡⍢  ⍣⍤⍥ ⍦⍧⍨ ⍩⍪⍫ ⍬⍭⍮ ⍯⍰⍱ ⍲⍳⍴ ⍵⍶⍷ ⍸⍹⍺ ⍻⍼⍽ ⍾⍿⎀ ⎁⎂⎃ ⎄⎅⎆ ⎇⎈⎉ ⎊⎋⎌ ⎍⎎⎏ ⎐⎑⎒ ⎓⎔⎕ ⎖⎗⎘ ⎙⎚⎛ ⎜⎝⎞ ⎟⎠⎡ ⎢⎣⎤ ⎥⎦⎧ ⎨⎩⎪ ⎫⎬⎭ ⎮⎯⎰ ⎱⎲⎳ ⎴⎵⎶ ⎷⎸⎹ ⎺⎻⎼
  ⎽⎾ ⎿⏀⏁ ⏂⏃⏄ ⏅⏆⏇ ⏈⏉⏊ ⏋⏌⏍ ⏎⏏⏐ ⏑⏒⏓ ⏔⏕⏖ ⏗⏘⏙ ⏚⏛⏜ ⏝⏞⏟ ⏠⏡⏢ ⏣⏤⏥ ⏦⏧⏨ ⏩⏪⏫ ⏬⏭⏮ ⏯⏰⏱ ⏲⏳⏴ ⏵⏶⏷ ⏸⏹⏺ ⏻⏼⏽ ⏾⏿

}
END

  TEX_FOOTER = "\\end{document}"

  class << self

    def create_comparison_pdf(pdf_file, font_families, base_font_family: "Teretisma")

      base_fonts = Font.where(:family => base_font_family).collect{|font| font.family_fonts}.flatten.uniq.sort_by{|font|
        style_index = 100
        if font.sub_family == "Regular"
          style_index = 0
        elsif font.sub_family == "Bold"
          style_index = 2
        elsif font.sub_family == "Italic"
          style_index = 1
        elsif font.sub_family == "Bold Italic"
          style_index = 3
        end

        [font_families.index(font.family), style_index]
      }


      fonts = Font.where(:family => font_families).collect{|font| font.family_fonts}.flatten.uniq.sort_by{|font|
        style_index = 100
        if font.sub_family == "Regular"
          style_index = 0
        elsif font.sub_family == "Bold"
          style_index = 2
        elsif font.sub_family == "Italic"
          style_index = 1
        elsif font.sub_family == "Bold Italic"
          style_index = 3
        end

        [font_families.index(font.family), style_index]
      }
      File.open("#{File.dirname(__FILE__)}/test.css", 'w+'){|file|
        (fonts + base_fonts).each_with_index{|font, index|

          file.puts "@font-face {"
          file.puts "  font-family: '#{font.family}';"
          file.puts "  src: url(data:font/#{File.extname(font.file_locations.first) == '.otf' ? 'opentype' : 'truetype'};charset=utf-8;base64,#{Base64.encode64(File.read(font.file_locations.first)).gsub(/\s+/, "")});"
          if font.sub_family == "Regular"
          elsif font.sub_family == "Bold"
            file.puts "  font-weight: bold;"
          elsif font.sub_family == "Italic"
            file.puts "  font-style: italic;"
          elsif font.sub_family == "Bold Italic"
            file.puts "  font-weight: bold;"
            file.puts "  font-style: italic;"
          end
          file.puts "}"


          file.puts
          file.puts ".font-#{font.id} {"
          file.puts "   "
          file.puts "   font-family: '#{font.family}';"
          if font.sub_family == "Regular"
          elsif font.sub_family == "Bold"
            file.puts "  font-weight: bold;"
          elsif font.sub_family == "Italic"
            file.puts "  font-style: italic;"
          elsif font.sub_family == "Bold Italic"
            file.puts "  font-weight: bold;"
            file.puts "  font-style: italic;"
          end
          file.puts "   font-size: 12pt;"
          file.puts "}"
          file.puts ".font-comparison {"
          file.puts " clear: both;"
          file.puts " "
          file.puts "}"
          file.puts ".page-break {"
          file.puts " page-break-after: always;"
          file.puts " "
          file.puts "}"


        }
      }

      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.body {
            fonts.each_with_index{|font, index|

              _hash = font.compare(base_font_family)

              doc.div(class: 'font-comparison') {
                doc.div(class: 'left' , style: "float:left; width:45%;") {
                  doc.div(class: 'font_id') {
                    doc.text "ID: #{font.id}"
                  }

                  doc.div(class: 'font_name') {
                    doc.text "Name: #{font.family}"
                  }

                  doc.div(class: 'font_name') {
                    doc.text "Stil: #{font.sub_family}"
                  }
                  doc.div(class: 'font_information') {
                    doc.text "% Glyphen: #{_hash[:percentage_glyphs]}"
                  }

                  doc.div(class: 'font_information') {
                    doc.text "% Features: #{_hash[:percentage_features]}"
                  }

                  doc.div(class: 'font_information') {
                    doc.text "Anzahl fehlende Gylphen: #{_hash[:missing_glyph_code_points_count]}"
                  }

                  doc.div(class: 'font_information') {
                    doc.text "Anzahl fehlende Features: #{_hash[:missing_features_count]}"
                  }

                  doc.div(class: "font-#{font.id}") {
                    doc.text font.replace_missing_glyphs(BLINDTEXT)
                  }
                }


                compare_font = font.comparison_font(base_font_family)
                doc.div(class: 'right', style: "float:right; width:45%;") {
                  if compare_font

                    doc.div(class: 'font_id') {
                      doc.text "ID: #{compare_font.id}"
                    }

                    doc.div(class: 'font_name') {
                      doc.text "Name: #{compare_font.family}"
                    }

                    doc.div(class: 'font_name') {
                      doc.text "Stil: #{compare_font.sub_family}"
                    }
                    doc.div(class: 'font_information') {
                      doc.text " "
                    }

                    doc.div(class: 'font_information') {
                      doc.text " "
                    }

                    doc.div(class: 'font_information') {
                      doc.text " "
                    }

                    doc.div(class: 'font_information') {
                      doc.text " "
                    }

                    doc.div(class: "font-#{compare_font.id}") {
                      doc.text compare_font.replace_missing_glyphs(BLINDTEXT)
                    }
                  end
                }

              }
              doc.div(class: 'page-break') {
                doc.text " "
              }

            }
          }
        }
      end

      kit = PDFKit.new(builder.to_html, :page_size => 'Letter')
      kit.stylesheets << "#{File.dirname(__FILE__)}/test.css"
      file = kit.to_file(pdf_file)


    end

    def create_font_test_pdf(pdf_file, regular_font_location)
      Dir.mktmpdir do |dir|

        FileUtils.mkdir_p("#{dir}/fonts/1/")
        FileUtils.cp(regular_font_location, "#{dir}/fonts/1/#{File.basename(regular_font_location).gsub(/[\[\]]/,'_')}")

        File.open("#{dir}/main.tex",'w+'){|file|
          file.puts TEX_HEADER
          file.puts "\\XeTeXtracingfonts=1"
          file.puts "\\newfontfamily{\\nf}[Path=./fonts/1/]{NewFont}"
          file.puts "\\nf"
          file.puts "ΔΕΖ"
          file.puts
          file.puts "\\blindtext"
          file.puts TEX_FOOTER
        }
        #puts File.read("#{dir}/main.tex")
        puts `cd #{dir}; /usr/local/texlive/2015/bin/x86_64-linux/xelatex --interaction=batchmode main`
        FileUtils.cp("#{dir}/main.pdf", pdf_file)
      end

    end


    def create_fonts_tex_pdf(pdf_file, font_families, base_font_family, type: :blind )
      regular_base_font = Font.where(family: base_font_family).first.regular_font
      bold_base_font = Font.where(family: base_font_family).first.bold_font
      italic_base_font = Font.where(family: base_font_family).first.italic_font
      bold_italic_base_font = Font.where(family: base_font_family).first.bold_italic_font


      Dir.mktmpdir do |dir|
        base_font_spec = regular_base_font.fontspec("#{dir}/fonts/#{regular_base_font.id}/")
        FileUtils.mkdir_p("#{dir}/fonts/#{regular_base_font.id}")
        FileUtils.cp(regular_base_font&.file_locations&.first, "#{dir}/fonts/#{regular_base_font.id}/#{File.basename(regular_base_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if regular_base_font&.file_locations&.first
        FileUtils.cp(bold_base_font&.file_locations&.first, "#{dir}/fonts/#{regular_base_font.id}/#{File.basename(bold_base_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if bold_base_font&.file_locations&.first
        FileUtils.cp(italic_base_font&.file_locations&.first, "#{dir}/fonts/#{regular_base_font.id}/#{File.basename(italic_base_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if italic_base_font&.file_locations&.first
        FileUtils.cp(bold_italic_base_font&.file_locations&.first, "#{dir}/fonts/#{regular_base_font.id}/#{File.basename(bold_italic_base_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if bold_italic_base_font&.file_locations&.first






        File.open("#{dir}/main.tex",'w+'){|file|
          file.puts TEX_HEADER

          font_families.each{|font_family|

            regular_font = Font.where(family: font_family).first.regular_font
            bold_font = Font.where(family: font_family).first.bold_font
            italic_font = Font.where(family: font_family).first.italic_font
            bold_italic_font = Font.where(family: font_family).first.bold_italic_font

            next unless regular_font

            _regular_hash = {}
            _bold_hash = {}
            _italic_hash = {}
            _bold_italic_hash = {}

            _regular_hash = regular_font.compare(base_font_family) if regular_font
            _bold_hash = bold_font.compare(base_font_family) if bold_font
            _italic_hash = italic_font.compare(base_font_family) if italic_font
            _bold_italic_hash = bold_italic_font.compare(base_font_family) if bold_italic_font



            font_spec = regular_font.fontspec("#{dir}/fonts/#{regular_font.id}/")
            FileUtils.mkdir_p("#{dir}/fonts/#{regular_font.id}")

            FileUtils.cp(regular_font&.file_locations&.first, "#{dir}/fonts/#{regular_font.id}/#{File.basename(regular_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if regular_font&.file_locations&.first and File.exist?(regular_font&.file_locations&.first)
            FileUtils.cp(bold_font&.file_locations&.first, "#{dir}/fonts/#{regular_font.id}/#{File.basename(bold_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if bold_font&.file_locations&.first and File.exist?(bold_font&.file_locations&.first)
            FileUtils.cp(italic_font&.file_locations&.first, "#{dir}/fonts/#{regular_font.id}/#{File.basename(italic_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if italic_font&.file_locations&.first and File.exist?(italic_font&.file_locations&.first)
            FileUtils.cp(bold_italic_font&.file_locations&.first, "#{dir}/fonts/#{regular_font.id}/#{File.basename(bold_italic_font&.file_locations&.first).gsub(/[\[\]]/,'_')}") if bold_italic_font&.file_locations&.first and File.exist?(bold_italic_font&.file_locations&.first)

            #[regular_font, bold_font, italic_font, bold_italic_font].each{|font|

            if type == :blind

              file.puts "#{font_spec}
Fontname: #{regular_font.family} #{regular_font.sub_family} #{regular_font.id}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {%
Glyphen: #{_regular_hash[:percentage_glyphs].round(2)}\\% (#{_regular_hash[:missing_glyph_code_points_count]} fehlen) Features: #{_regular_hash[:percentage_features].round(2)}\\% (#{_regular_hash[:missing_features_count]} fehlen)\\hfill\\break
Schnittmenge Features: #{(regular_font.features.pluck(:short_name) & regular_base_font.features.pluck(:short_name)).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

\\blindtext\\vfill\\break
#{base_font_spec}
Fontname: #{regular_base_font.family} #{regular_base_font.sub_family}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {vorhandene Features: #{regular_base_font.features.pluck(:short_name).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

\\blindtext
\\vfill\\break" if regular_font
            file.puts "#{font_spec}
Fontname: #{italic_font.family} #{italic_font.sub_family} #{italic_font.id}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {%
Glyphen: #{_italic_hash[:percentage_glyphs].round(2)}\\% (#{_italic_hash[:missing_glyph_code_points_count]} fehlen) Features: #{_italic_hash[:percentage_features].round(2)}\\% (#{_italic_hash[:missing_features_count]} fehlen)\\hfill\\break
Schnittmenge Features: #{(italic_font.features.pluck(:short_name) & italic_base_font.features.pluck(:short_name)).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

{\\noindent\\textit{\\blindtext}}

\\vfill\\break
#{base_font_spec}
Fontname: #{italic_base_font.family} #{italic_base_font.sub_family}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {vorhandene Features: #{italic_base_font.features.pluck(:short_name).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

{\\noindent\\textit{\\blindtext}}
\\vfill\\break" if italic_font
            file.puts "#{font_spec}
Fontname: #{bold_font.family} #{bold_font.sub_family} #{bold_font.id}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {%
Glyphen: #{_bold_hash[:percentage_glyphs].round(2)}\\% (#{_bold_hash[:missing_glyph_code_points_count]} fehlen) Features: #{_bold_hash[:percentage_features].round(2)}\\% (#{_bold_hash[:missing_features_count]} fehlen)\\hfill\\break
Schnittmenge Features: #{(bold_font.features.pluck(:short_name) & bold_base_font.features.pluck(:short_name)).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

{\\noindent
      \\textbf{\\blindtext}
}

\\vfill\\break
#{base_font_spec}
Fontname: #{bold_base_font.family} #{bold_base_font.sub_family}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {vorhandene Features: #{bold_base_font.features.pluck(:short_name).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

{\\noindent
      \\textbf{\\blindtext}
}

\\vfill\\break" if bold_font
            file.puts "#{font_spec}
Fontname: #{bold_italic_font.family} #{bold_italic_font.sub_family} #{bold_italic_font.id}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {%
Glyphen: #{_bold_italic_hash[:percentage_glyphs].round(2)}\\% (#{_bold_italic_hash[:missing_glyph_code_points_count]} fehlen) Features: #{_bold_italic_hash[:percentage_features].round(2)}\\% (#{_bold_italic_hash[:missing_features_count]} fehlen)\\hfill\\break
Schnittmenge Features: #{(bold_italic_font.features.pluck(:short_name) & bold_italic_base_font.features.pluck(:short_name)).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

{\\bf\\noindent
        \\textit{
                \\blindtext

        }
}\\vfill\\break
#{base_font_spec}
Fontname: #{bold_italic_base_font.family} #{bold_italic_base_font.sub_family}\\hfill\\break\\vskip1mm
\\vbox to 16.2mm {vorhandene Features: #{bold_italic_base_font.features.pluck(:short_name).join(", ")}}

Schriftbeispiele\\hfill\\break\\noindent

{\\bf\\noindent
        \\textit{
                \\blindtext

        }
}\\vfill\\break
%
" if bold_italic_font
            elsif type == :numbers

              file.puts "#{base_font_spec}#{regular_font.family}\\hfill\\break"

              file.puts "Fontname: #{regular_base_font.family} #{regular_base_font.sub_family}\\hfill\\break
Fontname: #{regular_font.family} #{regular_font.sub_family} #{regular_font.id}\\hfill\\break
\\noindent{1234567890}\\hfill\\break
#{font_spec}
\\noindent{1234567890}\\hfill\\break
#{base_font_spec}" if regular_font


file.puts "#{base_font_spec}
Fontname: #{italic_base_font.family} #{italic_base_font.sub_family}\\hfill\\break
Fontname: #{italic_font.family} #{italic_font.sub_family} #{italic_font.id}\\hfill\\break
{\\noindent\\textit{1234567890}}\\hfill\\break
#{font_spec}
{\\noindent\\textit{1234567890}}\\hfill\\break
#{base_font_spec}" if italic_font


file.puts "#{base_font_spec}
Fontname: #{bold_base_font.family} #{bold_base_font.sub_family}\\hfill\\break
Fontname: #{bold_font.family} #{bold_font.sub_family} #{bold_font.id}\\hfill\\break
{\\noindent\\textbf{1234567890}}\\hfill\\break
#{font_spec}
{\\noindent\\textbf{1234567890}}\\hfill\\break
#{base_font_spec}" if bold_font

file.puts "#{base_font_spec}
Fontname: #{bold_italic_base_font.family} #{bold_italic_base_font.sub_family}\\hfill\\break
Fontname: #{bold_italic_font.family} #{bold_italic_font.sub_family} #{bold_italic_font.id}\\hfill\\break
{\\bf\\noindent\\textit{1234567890}}\\hfill\\break
#{font_spec}
{\\bf\\noindent\\textit{1234567890}}\\hfill\\break
#{base_font_spec}" if bold_italic_font
                   file.puts "\\vfill\\break"


                  end


          }
          file.puts TEX_FOOTER
        }
        puts `cd #{dir}; /usr/local/texlive/2015/bin/x86_64-linux/xelatex --interaction=batchmode main`
        FileUtils.cp("#{dir}/main.pdf", pdf_file)

      end
    end



  end

end
