require 'pry'
class ParseFile

  def initialize(file_name)
    @file_name = file_name
    @section_content = {}
    @index_of_section_headers = []
    @sections = []
    self.parse
  end

  def parse
    file_string = ""
    File.readlines(@file_name).each do |line|
      section_or_key?(line)
      # if line.include?("\[") || line.include?("\:")
      #   add_star(line)
      # end
      file_string += line.strip + " "
    end
    file_arr = file_string.split("*")

    file_arr.each do |line|
      if line.match(/\[[a-zA-Z\s]+\]/)
        clean(line)
        @section_content[line] = []
      end
    end
    get_section_index(file_arr)

    @section_content.each do |section_title, content_arr|
      @sections << section_title
    end
      line_number_sections = Hash[@index_of_section_headers.zip(@sections)]
      line_number_sections.each do |line_num, section_title|
        file_arr.each_with_index do |word, index|
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

  def get_value(section, key)
    @section_content.each do |sect, content|
      if section == sect
        content.each do |topic|
          return convert(topic[key]) if topic[key]
        end
      end
    end
  end

  def section_or_key?(line)
    if line.include?("\[") || line.include?("\:")
        add_star(line)
    end
  end


##################################
# Writing to a file

  def write(section, key, value)
    if @section_content[section]
      @section_content[section] << (Hash.try_convert(key => value))
    else
      @section_content[section] = (Hash.try_convert(key => value))
    end
    self.save
  end

  def save
    File.open('test2.dos', 'w') { |file|
      @section_content.each do |section, content|
        file << "\n\r[#{section}]\n\r"
        @section_content[section].each do |content_hash|
          # if content_hash.values[0].length > 60

          file << "#{format_content_hash(content_hash)}\n\r"
        end
      end
    }
  end
######################

private

  def get_section_index(file_arr)
    file_arr.each_with_index do |word, index|
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

newbie = ParseFile.new('test.dos')
p newbie.get_value("header", "project")
p newbie.get_value("header", "budget")
p newbie.get_value("header", "accessed")
p newbie.get_value("meta data", "description")
p newbie.get_value("meta data", "correction text")
p newbie.get_value("trailer", "budget")



newbie.save
newbie.write("header", "math", "fun")
newbie.write("friends", "weekend", "funz")

