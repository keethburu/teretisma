# coding: utf-8
require "yaml"
require "csv"
require "unicode/categories"
class FontManager

  require "#{File.dirname(__FILE__)}/models/font_db_connection.rb"
  require "#{File.dirname(__FILE__)}/models/feature.rb"
  require "#{File.dirname(__FILE__)}/models/font_feature.rb"
  require "#{File.dirname(__FILE__)}/models/font_glyph.rb"
  require "#{File.dirname(__FILE__)}/models/font.rb"
  require "#{File.dirname(__FILE__)}/models/glyph.rb"
  require "#{File.dirname(__FILE__)}/extract_info_lib.rb"
  require "#{File.dirname(__FILE__)}/extract_info_lib.rb"
  require "#{File.dirname(__FILE__)}/pdf_creator.rb"

  RANKING_CONFIGURATION = {
    :features => 1,
    :glyphs => 10,
    :sub_families => 50
  }

  DIACRITICS = ("0300".hex.."036F".hex).to_a +  ("1AB0".hex.."1AFF".hex).to_a + ("1DC0".hex.."1DFF".hex).to_a + ("20D0".hex.."20FF".hex).to_a + ("FE20".hex.."FE2F".hex).to_a

  SERIF_FAMILIES = ["EB Garamond 08", "Literata Book Medium", "Literata Book SemiBold", "Literata", "Alegreya Black", "Alegreya ExtraBold", "Alegreya Medium", "EB Garamond 12", "Libertinus Serif Semibold", "Noto Serif Blk", "Noto Serif Cond Blk", "Noto Serif Cond ExtBd", "Noto Serif Cond ExtLt", "Noto Serif Cond Light", "Noto Serif Cond Med", "Noto Serif Cond SemBd", "Noto Serif Cond Thin", "Noto Serif ExtBd", "Noto Serif ExtCond Blk", "Noto Serif ExtCond ExtBd", "Noto Serif ExtCond ExtLt", "Noto Serif ExtCond Light", "Noto Serif ExtCond Med", "Noto Serif ExtCond SemBd", "Noto Serif ExtCond Thin", "Noto Serif ExtLt", "Noto Serif Light", "Noto Serif Med", "Noto Serif SemBd", "Noto Serif SemCond Blk", "Noto Serif SemCond ExtBd", "Noto Serif SemCond ExtLt", "Noto Serif SemCond Light", "Noto Serif SemCond Med", "Noto Serif SemCond SemBd", "Noto Serif SemCond Thin", "Noto Serif Thin", "Alegreya", "Literata Book", "Linux Libertine O", "Libertinus Serif", "Noto Serif Cond", "Noto Serif ExtCond", "Noto Serif SemCond", "Noto Serif"]

  SANS_SERIF_FAMILIES = ["Fira Sans Condensed ExtraLight", "Fira Sans Condensed ExtraBold", "Fira Sans Condensed Light", "Fira Sans Condensed Medium", "Fira Sans Condensed SemiBold", "Fira Sans Condensed Thin", "Fira Sans Compressed ExtraBold", "Fira Sans Compressed Heavy", "Fira Sans Compressed Medium", "Fira Sans Compressed SemiBold", "Fira Sans Compressed Book", "Fira Sans Compressed Eight", "Fira Sans Compressed ExtraLight", "Fira Sans Compressed Four", "Fira Sans Compressed Hair", "Fira Sans Compressed Light", "Fira Sans Compressed Thin", "Fira Sans Compressed Two", "Fira Sans Compressed UltraLight", "Fira Sans Eight", "Fira Sans Four", "Fira Sans Hair", "Fira Sans Two", "Fira Sans Ultra", "Fira Sans Black", "Fira Sans Condensed Black", "Fira Sans Extra Condensed Black", "Fira Sans Extra Condensed ExtraBold", "Fira Sans Extra Condensed ExtraLight", "Fira Sans Extra Condensed Light", "Fira Sans Extra Condensed Medium", "Fira Sans Extra Condensed SemiBold", "Fira Sans Extra Condensed Thin", "Fira Sans Book", "Fira Sans ExtraBold", "Fira Sans ExtraLight", "Fira Sans Heavy", "Fira Sans SemiBold", "Fira Sans Thin", "Fira Sans UltraLight", "Fira Sans Light", "Fira Sans Medium", "Alegreya Sans Black", "Alegreya Sans ExtraBold", "Alegreya Sans Light", "Alegreya Sans Medium", "Alegreya Sans Thin", "Noto Sans Blk", "Noto Sans Cond Blk", "Noto Sans Cond ExtBd", "Noto Sans Cond ExtLt", "Noto Sans Cond Light", "Noto Sans Cond Med", "Noto Sans Cond SemBd", "Noto Sans Cond Thin", "Noto Sans ExtBd", "Noto Sans ExtCond Blk", "Noto Sans ExtCond ExtBd", "Noto Sans ExtCond ExtLt", "Noto Sans ExtCond Light", "Noto Sans ExtCond Med", "Noto Sans ExtCond SemBd", "Noto Sans ExtCond Thin", "Noto Sans ExtLt", "Noto Sans Light", "Noto Sans Med", "Noto Sans SemBd", "Noto Sans SemCond Blk", "Noto Sans SemCond ExtBd", "Noto Sans SemCond ExtLt", "Noto Sans SemCond Light", "Noto Sans SemCond Med", "Noto Sans SemCond SemBd", "Noto Sans SemCond Thin", "Noto Sans Thin", "Libertinus Sans", "Fira Sans Condensed", "Alegreya Sans", "Fira Sans", "Fira Sans Compressed", "Fira Sans Extra Condensed", "Noto Sans", "Noto Sans Cond", "Noto Sans ExtCond", "Noto Sans SemCond", "Linux Biolinum O"]

  LOW_GLYPH_COVERAGE = ["PT Serif", "Junicode", "Libre Caslon Text", "PT Serif Caption", "Fanwood Text", "Alegreya Sans", "Fira Sans", "Fira Sans Condensed", "Alegreya Sans Thin", "Alegreya Sans Medium", "Alegreya Sans ExtraBold", "Alegreya Sans Black", "Fira Sans Condensed Thin", "Fira Sans Condensed Thin", "Fira Sans Condensed SemiBold", "Fira Sans Condensed Medium", "Fira Sans Condensed Light", "Fira Sans Condensed ExtraBold", "Fira Sans Condensed ExtraLight", "Alegreya Sans Light", "Alegreya", "Alegreya Medium", "Alegreya ExtraBold", "Alegreya Black", "EB Garamond 08"]

  SENSELESS_FONTS = ["Fira Sans Two", "Fira Sans Hair", "Fira Sans Four", "Fira Sans Eight", "Fira Sans Compressed Two", "Fira Sans Compressed Four", "Fira Sans Compressed Eight"]

  NO_FRENCH_REN_ANTIGUA_FONTS = ["Noto Serif", "Noto Serif Blk", "Noto Serif Cond Blk", "Noto Serif Cond ExtBd", "Noto Serif Cond ExtLt", "Noto Serif Cond Light", "Noto Serif Cond Med", "Noto Serif Cond SemBd", "Noto Serif Cond Thin", "Noto Serif ExtBd", "Noto Serif ExtCond Blk", "Noto Serif ExtCond ExtBd", "Noto Serif ExtCond ExtLt", "Noto Serif ExtCond Light", "Noto Serif ExtCond Med", "Noto Serif ExtCond SemBd", "Noto Serif ExtCond Thin", "Noto Serif ExtLt", "Noto Serif Light", "Noto Serif Med", "Noto Serif SemBd", "Noto Serif SemCond Blk", "Noto Serif SemCond ExtBd", "Noto Serif SemCond ExtLt", "Noto Serif SemCond Light", "Noto Serif SemCond Med", "Noto Serif SemCond SemBd", "Noto Serif SemCond Thin", "Noto Serif Thin", "Noto Serif Cond", "Noto Serif ExtCond", "Noto Serif SemCond", "Literata Book", "Literata Book"]



  class << self
    def fill_font_lib(directory)
      font_files = (Dir.glob("#{directory}/*.[ot]tf") + Dir.glob("#{directory}/**/*.[ot]tf"))
      font_files.sort!
      count = font_files.length
      font_files.each_with_index{|font_file, index|

        puts "#{(index + 1).to_s.rjust(7)}/#{count} (#{(((index + 1)/count.to_f)*100).round(2)}%) #{font_file}"
        font_info_hash = extract_infos_for_font(font_file)
        import_into_db(font_file, font_info_hash)
      }
    end

    def import_into_db(font_file, info_hash)
      begin
        raise "Name, Family und Subfamily werden erwartet (gefunden: #{info_hash.keys}) #{font_file}" unless info_hash["Family"] and (info_hash["Subfamily"] or info_hash["Preferred subfamily"]) and info_hash["Full name"]
        font = Font.where(:name => info_hash["Full name"], :family => info_hash["Family"], :sub_family => (info_hash["Subfamily"] ? info_hash["Subfamily"] : info_hash["Preferred subfamily"])).first_or_initialize
        font.add_file_location(font_file)
        font.add_infos_from_hash(info_hash)
        font.save!
      rescue StandardError => e
        puts "Problem mit #{font_file}"
        puts e.message
      end
    end

    def all_fonts
      Font.all
    end

    def create_csv(csv_file_name: 'config/chars.csv', base_font_name: 'Teretisma-Regular', first_alt_sans_font_family: 'Noto Sans SemCond', first_alt_serif_font_family: 'Noto Serif SemCond')
      all_unicode_points = Font.where(name: base_font_name).first.glyphs.pluck(:unicode_point)
      all_unicode_points += (Font.where(family: first_alt_sans_font_family).first.glyph_code_points_contained_in_all_sub_families & Font.where(family: first_alt_serif_font_family).first.glyph_code_points_contained_in_all_sub_families)
      all_unicode_points.uniq!
      all_unicode_points.sort!

      sans_regular_alt = Font.where(family: first_alt_sans_font_family).first.regular_font
      sans_italic_alt = Font.where(family: first_alt_sans_font_family).first.italic_font
      sans_bold_alt = Font.where(family: first_alt_sans_font_family).first.bold_font
      sans_bold_italic_alt = Font.where(family: first_alt_sans_font_family).first.bold_italic_font

      serif_regular_alt = Font.where(family: first_alt_serif_font_family).first.regular_font
      serif_italic_alt = Font.where(family: first_alt_serif_font_family).first.italic_font
      serif_bold_alt = Font.where(family: first_alt_serif_font_family).first.bold_font
      serif_bold_italic_alt = Font.where(family: first_alt_serif_font_family).first.bold_italic_font


      sans_regular_alt_file = File.basename(sans_regular_alt.file_locations.first)
      sans_italic_alt_file = File.basename(sans_italic_alt.file_locations.first)
      sans_bold_alt_file = File.basename(sans_bold_alt.file_locations.first)
      sans_bold_italic_alt_file = File.basename(sans_bold_italic_alt.file_locations.first)


      serif_regular_alt_file = File.basename(serif_regular_alt.file_locations.first)
      serif_italic_alt_file = File.basename(serif_italic_alt.file_locations.first)
      serif_bold_alt_file = File.basename(serif_bold_alt.file_locations.first)
      serif_bold_italic_alt_file = File.basename(serif_bold_italic_alt.file_locations.first)


      CSV::open(csv_file_name, 'w:utf-8', col_sep: ';') do |csv_object|
        csv_object << ["char",'codepoint','sans-regular','sans-italic','sans-bold','sans-bold-italic','serif-regular','serif-italic','serif-bold','serif-bold-italic',"in-#{base_font_name.downcase}"]
        all_unicode_points.each do |unicode_point|
          code_point = unicode_point.gsub('uni','')
          char = code_point.hex.chr(Encoding::UTF_8)

          sans_regular = (sans_regular_alt.glyphs.where(unicode_point: unicode_point).exists? ? sans_regular_alt_file : nil)
          sans_italic = (sans_italic_alt.glyphs.where(unicode_point: unicode_point).exists? ? sans_italic_alt_file : nil)
          sans_bold = (sans_bold_alt.glyphs.where(unicode_point: unicode_point).exists? ? sans_bold_alt_file : nil)
          sans_bold_italic = (sans_bold_italic_alt.glyphs.where(unicode_point: unicode_point).exists? ? sans_bold_italic_alt_file : nil)

          serif_regular = (serif_regular_alt.glyphs.where(unicode_point: unicode_point).exists? ? serif_regular_alt_file : nil)
          serif_italic = (serif_italic_alt.glyphs.where(unicode_point: unicode_point).exists? ? serif_italic_alt_file : nil)
          serif_bold = (serif_bold_alt.glyphs.where(unicode_point: unicode_point).exists? ? serif_bold_alt_file : nil)
          serif_bold_italic = (serif_bold_italic_alt.glyphs.where(unicode_point: unicode_point).exists? ? serif_bold_italic_alt_file : nil)

          in_base = Font.where(name: base_font_name).first.glyphs.where(unicode_point: unicode_point).exists?

          csv_object << [char, code_point, sans_regular, sans_italic, sans_bold, sans_bold_italic, serif_regular, serif_italic, serif_bold, serif_bold_italic, in_base]

        end

      end

    end


    def find_alternative_family(source_family,
                                must_have_features: ["c2sc", "case", "ccmp", "frac", "kern", "liga", "onum", "pnum", "tnum", "smcp"],
                                must_have_glyphs: [
                                  "uni0041", # A -> Latin
                                  "uni00C0", # À -> Latin extended
                                  "uni0396", # Ζ -> griechisch
                                  "uni1F00" # ἀ -> altgriechisch
                                ])
      font = Font.where(:family => source_family).first
      source_sub_families = font.sub_families
      source_glyph_code_points = font.glyph_code_points_contained_in_all_sub_families
      source_features = font.feature_short_names_contained_in_all_sub_families
      source_sub_families_count = source_sub_families.length
      source_glyph_code_points_count = source_glyph_code_points.length
      source_features_count = source_features.length

      all_fonts = Font.all
      fonts_with_all_must_have_features = all_fonts.select{|font| (must_have_features - font.features.pluck(:short_name)).empty?}
      fonts_with_all_must_have_glyphs_and_all_must_have_features = fonts_with_all_must_have_features.select{|font| (must_have_glyphs - font.glyphs.pluck(:unicode_point)).empty?}
      other_families_array = (fonts_with_all_must_have_glyphs_and_all_must_have_features.collect(&:family) - [source_family]).uniq.collect{|other_family|
        first_family_font = Font.where(:family => other_family).first

        _sub_families = first_family_font.sub_families
        _glyph_code_points = first_family_font.glyph_code_points_contained_in_all_sub_families
        _features = first_family_font.feature_short_names_contained_in_all_sub_families
        missing_sub_families_count = (source_sub_families - _sub_families).length
        missing_glyph_code_points_count = (source_glyph_code_points - _glyph_code_points).length
        missing_features_count = (source_features - _features).length
        percentage_sub_families = ((source_sub_families_count - missing_sub_families_count) / source_sub_families_count.to_f)
        percentage_glyphs = ((source_glyph_code_points_count - missing_glyph_code_points_count) / source_glyph_code_points_count.to_f)
        percentage_features = ((source_features_count - missing_features_count) / source_features_count.to_f)
        [percentage_sub_families, percentage_glyphs, percentage_features, other_family, first_family_font]
      }.sort_by{|family_array|
        percentage_sub_families = family_array[0]
        percentage_glyphs = family_array[1]
        percentage_features = family_array[2]
        other_family = family_array[3]

        ###
        ### Calculate Ranking

        ((percentage_sub_families * RANKING_CONFIGURATION[:sub_families]) + (percentage_glyphs * RANKING_CONFIGURATION[:glyphs]) + (percentage_features * RANKING_CONFIGURATION[:features])) / (RANKING_CONFIGURATION[:sub_families] + RANKING_CONFIGURATION[:glyphs] + RANKING_CONFIGURATION[:features]).to_f
      }

      other_families_array.reject!{|family_array|
        (["Regular", "Italic"] - family_array[4].family_fonts.pluck(:sub_family)).length > 0
      }

      other_families_array.each{|family_array|
        percentage_sub_families = family_array[0]
        percentage_glyphs = family_array[1]
        percentage_features = family_array[2]
        other_family = family_array[3]
        font = family_array[4]

        puts "#{font.id.to_s.ljust(6)} #{other_family.ljust(60)} #{(percentage_sub_families * 100).to_s.ljust(5)} #{(percentage_glyphs * 100).round(2).to_s.ljust(5)} #{(percentage_features * 100).to_s.ljust(5)} #{font.family_fonts.pluck(:sub_family).join(", ")}"
      }
      return other_families_array.collect{|family_array| family_array[3]}

    end

    def pdf_for_best_alternative_fonts(source_family, output_pdf: 'test.pdf', exclude: [])
      other_families = find_alternative_family(source_family)
      other_families -= exclude
      #PdfCreator.create_comparison_pdf(output_pdf, other_families.last(limit).reverse, base_font_family: source_family)
      PdfCreator.create_fonts_tex_pdf(output_pdf, other_families.reverse, source_family)
    end











    def create_new_fonts(chars_config_file: 'config/chars.csv', config_file: 'config/config.yaml', source_font_dir: 'source_fonts/', target_font_dir: 'output/', new_font_name: 'Teretisma', base_font_regex: nil)
      table = CSV.parse(File.read(chars_config_file), headers: true, col_sep: ';')
      font_config = YAML.load(File.read(config_file))
      code_points = table.by_col[1]
      FileUtils.mkdir_p(target_font_dir) unless File.directory?(target_font_dir)

      table.headers.each_with_index{|table_header, table_header_index|
        next if table_header == 'char'
        next if table_header == 'codepoint'
        next if table_header.start_with?("in-")


        all_font_definitions = table.by_col[table_header_index]
        recombined_fonts = all_font_definitions.compact.select{|fd| fd.gsub(/\([^)]+\)$/,'') != fd}.uniq.collect{|fd| fd.gsub(/\([^)]+\)$/,'')}

        all_used_fonts = table.by_col[table_header_index].collect{|font|
          if font
            font.gsub(/\([^)]*\)$/,'')
          else
            nil
          end
        }
        used_fonts = all_used_fonts.compact
        base_font = used_fonts.max_by{|uf| used_fonts.count(uf)}
        if base_font_regex and regex_base_font = used_fonts.find{|uf| uf =~ base_font_regex}
          base_font = regex_base_font
        end

        sub_family = table_header.to_s.gsub("-",' ').split(" ").collect(&:capitalize).join(" ")
        type = "Sans"
        if sub_family =~ /Serif/
          type = "Serif"
        end
        sub_family.gsub!("Sans","")
        sub_family.gsub!("Serif","")
        sub_family.strip!


        puts "##########################################"
        puts "##########################################"
        puts "##########################################"
        puts "Subfamily: #{sub_family}"
        puts "Type: #{type}"
        puts "BaseFont: #{base_font}"
        additional_fonts = recombined_fonts + (used_fonts.uniq - [base_font])
        additional_fonts.uniq!

        puts "AdditionalFonts: #{additional_fonts}"

        output_font_name = "#{new_font_name.gsub(' ', '-')}-#{type}-#{sub_family.gsub(" ","-")}"
        output_font_family_name = "#{new_font_name} #{type}"
        Dir.mktmpdir do |tmp_dir|
          _tmp_base_font = File.join(source_font_dir, base_font)
          if additional_fonts.empty?
            puts "Rename Original Font #{base_font} to #{new_font_name.gsub(' ', '-')}-#{sub_family.gsub(" ","-")}"
            insert_glyphs_in_font_file(
                source_font: _tmp_base_font,
                target_font: _tmp_base_font,
                output_font_family_name: output_font_family_name,
                output_font_name: output_font_name,
                output_path: "#{tmp_dir}/",
                code_points: []
            )
            _tmp_base_font = File.join(tmp_dir, "#{new_font_name.gsub(' ', '-')}-#{type}-#{sub_family.gsub(" ","-")}.otf")
          else
            additional_fonts.each{|additional_font|
              puts "Additional Font #{additional_font}"
              code_points_to_replace = code_points.select.with_index{|code_point, index|
                all_used_fonts[index] == additional_font
              }.collect{|code_point| "uni#{code_point}"}
              code_points_to_replace = [] if additional_font == base_font

              code_points_to_replace_with_other = code_points.collect.with_index{|code_point, index|
                if all_font_definitions[index] && all_font_definitions[index].gsub(/\([^)]+\)$/,'') != all_font_definitions[index] && all_font_definitions[index].gsub(/\([^)]+\)$/,'') == additional_font
                  ["uni#{code_point}", all_font_definitions[index].gsub(/.*\(([^)]*)\)$/,'\1').codepoints.collect{|cp| "uni#{cp.to_s(16)}"}]
                else
                  nil
                end
              }.compact.to_h

              puts "Insert #{code_points_to_replace} from #{additional_font} into #{_tmp_base_font}"
              insert_glyphs_in_font_file(
                source_font: File.join(source_font_dir, additional_font),
                target_font: _tmp_base_font,
                output_font_family_name: output_font_family_name,
                output_font_name: output_font_name,
                output_path: "#{tmp_dir}/",
                code_points: code_points_to_replace,
                code_points_to_replace_with_other: code_points_to_replace_with_other
              )
              _tmp_base_font = File.join(tmp_dir, "#{new_font_name.gsub(' ', '-')}-#{type}-#{sub_family.gsub(" ","-")}.otf")
              puts "AAAAAAAAAAAAAAAAAAA"
              puts _tmp_base_font
              puts Dir.glob("#{tmp_dir}/*")

            }
          end

          adjust_font(
            source_font_file: _tmp_base_font,
            target_font_file: "#{target_font_dir}/#{output_font_name}.otf",
            font_name: output_font_name,
            family_name: output_font_family_name,
            weight: sub_family,
            scaling: font_config[:scaling],
            ascent: font_config[:ascent],
            descent: font_config[:descent],
            version: font_config[:version],
            copyright: font_config[:copyright]
          )

        end
      }

    end


    def insert_glyphs_in_font_file(source_font: Font.find(9), target_font: Font.find(2000), output_font_name: "NewFont", output_font_family_name: "NewFont Sans", output_path: "#{File.dirname(__FILE__)}/", code_points: ["uni0041", "uni0393", "uni0394", "uni0395", "uni0396", "uni0397"], code_points_to_replace_with_other: {})
      puts code_points_to_replace_with_other.to_yaml
      source_font_location = source_font.file_locations.first if source_font.is_a?(Font)
      target_font_location = target_font.file_locations.first if target_font.is_a?(Font)
      source_font_location ||= source_font
      target_font_location ||= target_font


      Dir.mktmpdir do |dir|
        FileUtils.cp(source_font_location, "#{dir}/source_font#{File.extname(source_font_location)}")
        FileUtils.cp(target_font_location, "#{dir}/target_font#{File.extname(target_font_location)}")

        unless code_points.empty?
          File.open("#{dir}/glyphs.txt",'w+'){|file|
            code_points.each{|code_point| file.puts code_point }
          }
          FileUtils.cp("bin/merge_fonts.py", "#{dir}/")
          puts `cd #{dir}; fontforge -lang=py -script merge_fonts.py glyphs.txt source_font#{File.extname(source_font_location)} #{dir}/target_font#{File.extname(target_font_location)} #{output_font_name} '#{output_font_family_name}'`
        end


        if !code_points_to_replace_with_other.keys.empty?
          code_points_to_replace_with_other.each{|target_glyph, source_glyphs|
            if File.exists?("#{dir}/#{output_font_name}.otf")
              FileUtils.cp("#{dir}/#{output_font_name}.otf", "#{dir}/source_font#{File.extname(source_font_location)}")
            else
              FileUtils.cp("#{dir}/target_font#{File.extname(target_font_location)}", "#{dir}/source_font#{File.extname(source_font_location)}")
            end

            FileUtils.cp("bin/combine_glyphs.ff", "#{dir}/")

            command = "cd #{dir}; fontforge -script combine_glyphs.ff source_font#{File.extname(source_font_location)} #{output_font_name} '#{output_font_family_name}' #{target_glyph} #{source_glyphs.join(" ")}"
            puts command
            puts `#{command}`
          }
        end


        FileUtils.cp("#{dir}/#{output_font_name}.otf", "#{output_path}/")
      end
    end

    def adjust_font(source_font_file: , target_font_file:, font_name:, family_name:, unique_id: nil, weight: "Regular", scaling: 1.0, version: 1.00, ascent: 800, descent: 200, copyright: "" )
      unless unique_id
        name_1 = font_name.gsub(/[[:punct:][:space:]]/,'').upcase
        unique_id = "#{version};#{name_1.upcase[0..3]};#{font_name}"
      end

      command = "fontforge -script #{File.join(File.dirname(__FILE__), '..', 'bin')}/adjust_font.ff #{source_font_file} #{target_font_file}  '#{font_name}' '#{weight}' '#{family_name}' '#{unique_id}' '#{version}' '#{copyright}' #{scaling} #{ascent} #{descent}"
      puts command
      puts `#{command}`
    end

    def create_math_font(new_font_name: "Teretisma", type: "Sans", sub_family: "Regular", config_file: 'config/config.yaml', source_math_font: 'source_fonts/NotoSansMath-Regular.ttf', target_font_dir: "output/", copyright: "Based on Noto Sans Math (Noto: Copyright 2015 Google Inc. All Rights Reserved.)")
      font_config = YAML.load(File.read(config_file))
      output_font_name = "#{new_font_name.gsub(' ', '-')}-#{type}-Math-#{sub_family.gsub(" ","-")}"
      output_font_family_name = "#{new_font_name} #{type} Math"
      adjust_font(
        source_font_file: source_math_font,
        target_font_file: "#{target_font_dir}/#{output_font_name}.otf",
        font_name: output_font_name,
        family_name: output_font_family_name,
        weight: sub_family,
        scaling: font_config[:scaling],
        ascent: font_config[:ascent],
        descent: font_config[:descent],
        version: font_config[:version],
        copyright: copyright
      )
    end
  end

end
