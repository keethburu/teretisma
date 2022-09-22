class Feature < FontDbConnection
  has_many :font_features
  has_many :features, through: :font_features
end
