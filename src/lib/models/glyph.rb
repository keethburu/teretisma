class Glyph  < FontDbConnection
  has_many :font_glyphs
  has_many :fonts, -> { distinct }, through: :font_glyphs
  
end
