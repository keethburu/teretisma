# coding: utf-8
class Font  < FontDbConnection
  has_many :font_glyphs
  has_many :glyphs, -> { distinct }, through: :font_glyphs
  has_many :font_features
  has_many :features, -> { distinct }, through: :font_features

  serialize :license, JSON
  serialize :file_locations, JSON
  serialize :misc_informations, JSON

  def add_infos_from_hash(hash)
    add_license_informations(hash)
    add_misc_informations(hash)
    add_feature_informations(hash)
    add_glyph_informations(hash)
  end

  def add_license_informations(hash)
    self.license = hash.slice("License", "License URL", "License Description", "Copyright")
  end

  def add_misc_informations(hash)
    _hash = hash.dup
    _hash.delete("Family")
    _hash.delete("Subfamily")
    _hash.delete("Full name")
    _hash.delete("License")
    _hash.delete("License URL")
    _hash.delete("License Description")
    _hash.delete("Copyright")
    _hash.delete(:features)
    _hash.delete(:glyphs)
    self.misc_informations = _hash
  end

  def add_file_location(location)
    self.file_locations ||= []
    self.file_locations << location
    self.file_locations = self.file_locations.uniq
  end

  def add_feature_informations(hash)
    _features = hash[:features]
    _features.each{|feature|
      self.features << Feature.where(:short_name => feature[0], :description => feature[1]).first_or_create
    } if _features
  end
  def add_glyph_informations(hash)
    _glyphs = hash[:glyphs]
    _glyphs.each{|glyph|
      self.glyphs << Glyph.where(:unicode_point => glyph[0], :glyph_number => glyph[1], :glyph_description => glyph[2]).first_or_create
    } if _glyphs
  end


  def feature_short_names
    features.pluck(:short_name).collect{|short_name|
      italic = !!(short_name =~ /It/i or short_name =~ /Obl/i)
      bold =   !!(short_name =~ /[B]d/i or short_name =~ /Bold/i)
      if italic and bold
        "BoldItalic"
      elsif italic
        "Italic"
      elsif bold
        "Bold"
      else
        "Regular"
      end
    }
  end

  def feature_short_names_contained_in_all_sub_families
    family_fonts.collect(&:feature_short_names).inject(nil){|array_containing_all, actual_array|
      array_containing_all = actual_array if array_containing_all.nil?
      array_containing_all = array_containing_all & actual_array
    }
  end

  def sub_families
    family_fonts.pluck(:sub_family)
  end

  def glyph_code_points
    glyphs.pluck(:unicode_point)
  end

  def glyph_code_points_contained_in_all_sub_families
    family_fonts.collect(&:glyph_code_points).inject(nil){|array_containing_all, actual_array|
      array_containing_all = actual_array if array_containing_all.nil?
      array_containing_all = array_containing_all & actual_array
    }
  end

  def family_fonts
    Font.where(:family => self.family)
  end

  def compare_family(source_family)
    font = Font.where(:family => source_family).first
    source_sub_families = font.sub_families
    source_glyph_code_points = font.glyph_code_points_contained_in_all_sub_families
    source_features = font.feature_short_names_contained_in_all_sub_families
    source_sub_families_count = source_sub_families.length
    source_glyph_code_points_count = source_glyph_code_points.length
    source_features_count = source_features.length

    other_family = self.family
    first_family_font = Font.where(:family => other_family).first
    _sub_families = first_family_font.sub_families
    _glyph_code_points = first_family_font.glyph_code_points_contained_in_all_sub_families
    _features = first_family_font.feature_short_names_contained_in_all_sub_families

    return {
      :missing_sub_families_count => (source_sub_families - _sub_families).length,
      :missing_glyph_code_points_count => (source_glyph_code_points - _glyph_code_points).length,
      :missing_features_count => (source_features - _features).length,
      :percentage_sub_families => ((source_sub_families_count - missing_sub_families_count) / source_sub_families_count.to_f),
      :percentage_glyphs => ((source_glyph_code_points_count - missing_glyph_code_points_count) / source_glyph_code_points_count.to_f),
      :percentage_features => ((source_features_count - missing_features_count) / source_features_count.to_f)
    }
  end


  def compare(source_family)
    source_font = comparison_font(source_family)
    return {} unless source_font
    return {
      :missing_glyph_code_points_count => (source_font.glyph_code_points - self.glyph_code_points).length,
      :missing_features_count => (source_font.features - self.features).length,
      :percentage_glyphs => ((source_font.glyph_code_points.length - (source_font.glyph_code_points - self.glyph_code_points).length) / source_font.glyph_code_points.length.to_f) * 100.0,
      :percentage_features => ((source_font.features.length - (source_font.features - self.features).length) / source_font.features.length.to_f) * 100.0
    }
  end

  def comparison_font(source_family)
    Font.where(:family => source_family, :sub_family => self.sub_family).first
  end


  def replace_missing_glyphs(text)
    _text = text.dup
    missing_symbols = (text.codepoints.collect{|cp| "uni" + cp.to_s(16).upcase.rjust(4, '0')} - self.glyphs.pluck(:unicode_point)).collect{|up| up.gsub("uni",'').hex.chr(Encoding::UTF_8)}
    missing_symbols.each{|ms| _text.gsub!(ms, '□')}
    return _text
  end


  def fontspec(path)
    "\\setmainfont{#{File.basename(regular_font&.file_locations&.first).gsub(/[\[\]]/,'_')}}[
        Path = #{path},
        BoldFont= #{File.basename(bold_font&.file_locations&.first.to_s).gsub(/[\[\]]/,'_')},
        ItalicFont     = #{File.basename(italic_font&.file_locations&.first.to_s).gsub(/[\[\]]/,'_')},
        BoldItalicFont = #{File.basename(bold_italic_font&.file_locations&.first.to_s).gsub(/[\[\]]/,'_')}]"

  end


  def regular_font
    Font.where(:family => self.family, :sub_family => 'Regular').first
  end

  def bold_font
    Font.where(:family => self.family, :sub_family => 'Bold').first
  end

  def bold_italic_font
    Font.where(:family => self.family, :sub_family => 'Bold Italic').first
  end

  def italic_font
    Font.where(:family => self.family, :sub_family => 'Italic').first
  end





end


