require "#{File.dirname(File.expand_path(__FILE__))}/extract_info_lib.rb"
require 'yaml'

base_font_directory = ARGV[0]
search_font_directory = ARGV[1]

base_font_infos = {}



(Dir.glob("#{base_font_directory}/*.[ot]tf") + Dir.glob("#{base_font_directory}/**/*.[ot]tf")).each{|font_file|
  _infos = extract_infos_for_font(font_file)
  base_font_infos[_infos['Family']] = {} unless base_font_infos[_infos['Family']]
  base_font_infos[_infos.delete('Family')][_infos.delete('Subfamily')] = _infos
}

puts base_font_infos.to_yaml
