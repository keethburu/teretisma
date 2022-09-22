require 'active_record'


class FontDbConnection < ActiveRecord::Base
  self.abstract_class = true

  ActiveRecord::Base.establish_connection(
    :adapter => "mysql2",
    :database => "fonts",
    :username => 'jasch',
    :password => 'gehe1m',
    :encoding => 'utf8'
  )
   # ActiveRecord::Schema.define do
   #     create_table :fonts do |table|
   #         table.column :name, :string
   #         table.column :family, :string
   #         table.column :sub_family, :string
   #         table.column :license, :text
   #         table.column :file_locations, :text
   #         table.column :misc_informations, :text
   #     end

   #     create_table :features do |table|
   #       table.column :short_name, :string
   #       table.column :description, :string
   #     end

   #     create_table :glyphs do |table|
   #       table.column :unicode_point, :string
   #       table.column :glyph_number, :string
   #       table.column :glyph_description, :string
   #     end

  
   #     create_table :font_features do |table|
   #       table.column :font_id, :integer, :index => true
   #       table.column :feature_id, :integer, :index => true
   #     end

   #     create_table :font_glyphs do |table|
   #       table.column :font_id, :integer, :index => true
   #       table.column :glyph_id, :integer, :index => true
   #     end
  
   # end
end
