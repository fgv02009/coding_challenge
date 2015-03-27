require 'pry'
class ParseFile
  #TESTED
  attr_reader :section_content, :file_str, :file_name, :section_content, :index_of_section_headers, :sections, :file_arr
  def initialize(file_name)
    @file_str = ""
    @file_name = file_name
    @section_content = {}
    @index_of_section_headers = []
    @sections = []
    @file_arr = []
  end
#TESTED
  def parse
    File.readlines(@file_name).each do |line|
      if section_or_key?(line)
        add_star(line)
      end
      @file_str += line.strip + " "
    end
    p @file_str
    set_section_content
    set_sections
    fill_section_content
  end

#TESTED
  def fill_section_content
      line_number_sections = Hash[@index_of_section_headers.zip(@sections)]
      line_number_sections.each do |line_num, section_title|
        @file_arr.each_with_index do |word, index|
          if index > @index_of_section_headers[-1]
            if @section_content.values.last.include?(word)
              next
            else
              @section_content.values.last << word
            end
          elsif index > line_num && index < @index_of_section_headers[@index_of_section_headers.index(line_num) + 1]
            @section_content[section_title] << word
          end
        end
    end

    set_key_values
  end
#TESTED#
  def set_section_content
    @file_arr = @file_str.split("*")
    @file_arr.each do |line|
      if line.match(/\[[a-zA-Z\s]+\]/)
        clean(line)
        @section_content[line] = []
      end
    end

    get_section_index
  end

#TESTED#
  def section_or_key?(line)
    line.include?("\[") || line.include?("\:")
  end

#TESTED#
  def set_sections
    @section_content.each do |section_title, content_arr|
      @sections << section_title
    end
  end

#TESTED#
  def get_value(section, key)
    @section_content.each do |sect, content|
      if section == sect
        content.each do |topic|
          return convert(topic[key]) if topic[key]
        end
      end
    end
  end




##################################
# Writing to a file

  def write(section, key, value)
    if @section_content[section]
      @section_content[section] << (Hash.try_convert(key => value))
    else
      @section_content[section] = [(Hash.try_convert(key => value))]
    end
    self.save
  end

  def save
    File.open('test2.dos', 'w') { |file|
      @section_content.each do |section, content|
        file << "\n[#{section}]\n"
        @section_content[section].each do |content_hash|
          if content_hash.values[0].length > 60 && !content_hash.values[0].include?("\n")
            split_line(content_hash)
          end

          file << "#{format_content_hash(content_hash)}\n"
        end
      end
    }

  end

  def split_line(content_hash)
    str = content_hash.values[0]
    length = str.length
    num_of_lines_to_split = length/60
    until num_of_lines_to_split == 0
      char = num_of_lines_to_split*60
      until str[char] == " "
        char -= 1
      end
      str.insert(char, "\n\r")
      num_of_lines_to_split -=1
    end
    return str
  end




######################

private

  def get_section_index
    @file_arr.each_with_index do |word, index|
      if @section_content.has_key?(word)
        @index_of_section_headers << index
      end
    end
    return @index_of_section_headers
  end

  def format_content_hash(content)
    content = content.flatten
    content.join(":")
  end

   def rid_white_spaces_quotes(text)
    text_arr = text.split('')
    until text_arr[0] != " "
      text_arr.shift
    end
    until text_arr[-1] != " "
      text_arr.pop
    end
    return text_arr.join('')
  end

  def rid_white_spaces_values(value)
    return value.chop!
  end

  def convert(value)
    if value.match(/[0-9]+(\.[0-9]+)/)
      value.to_f
    elsif value.match(/\d+/)
      value.to_i
    else
      return value
    end
  end

  def clean(section_header)
    section_header.gsub!(/\[/, "")
    section_header.gsub!(/\]/, "")
    return section_header.strip!
  end

  def add_star(line)
    line.insert(0,"*")
  end

  def set_key_values
    @section_content
    @section_content.each do |section, pairs|
      pairs.map! do |pair|
        pair = get_keys_values(pair)
      end
    end
    @section_content
  end

  def get_keys_values(pair)
    key = pair.split(":")[0]
    key = rid_white_spaces_quotes(key)
    value = pair.split(":")[1]
    value = rid_white_spaces_values(value)
    value = rid_white_spaces_quotes(value)
    pair = Hash.try_convert(key => value)
    return pair
  end

end

# newbie = ParseFile.new('test.dos')
# newbie.parse
# p newbie.get_value("header", "project")
# p newbie.get_value("header", "budget")
# p newbie.get_value("header", "accessed")
# p newbie.get_value("meta data", "description")
# p newbie.get_value("meta data", "correction text")
# p newbie.get_value("trailer", "budget")



# newbie.save
# newbie.write("header", "math", "fun")

# newbie2 = ParseFile.new('test2.dos')
# newbie2.parse
# newbie.write("friends", "weekend", "dinner in downtown Chicago")

