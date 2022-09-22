def extract_infos_for_font(font_file)
  infos_string = `otfinfo -i '#{font_file}'`
  unless $?.to_i == 0
    infos = {}
  else
    infos = {}
    key = nil
    infos_string.each_line{|line|
      if not(line =~ /^This license is/) and line =~ /(?=\n|^)([A-Za-z ]+):[[:space:]]/ 
        if key and infos[key]
          infos[key] = infos[key].strip
        end
        key = $1
        line.gsub!(/(?=\n|^)([A-Za-z ]+):[[:space:]]/,'')
      end
      if key
        if infos[key]
          infos[key] += line
        else
          infos[key] = line
        end
      end
    }
    if key and infos[key]
      infos[key] = infos[key].strip
    end
    
  end
  
  
  features = `otfinfo -f '#{font_file}'`.lines.to_a.collect{|line| line.split(/[[:space:]]+/,2).collect(&:strip)}
  features = [] unless $?.to_i == 0

  glyphs = `otfinfo -u '#{font_file}'`.lines.to_a.collect{|line| line.strip.split(/[[:space:]]+/)}
  glyphs = [] unless $?.to_i == 0
  return infos.merge(:features => features, :glyphs => glyphs)
  
end
