require 'pry'
class ParseFile
  attr_accessor :keys_values, :count_line, :sections_content
  def initialize(file_name)
    @file_name = file_name
    @sections = []
    @count_line = {}
    @keys_values = {}
    @sections_content = {}
    self.parse
    self.create_section_content
  end

  def parse
    count = 0
    File.readlines(@file_name).each do |line|
      section = get_sections(line)
      key_val = get_keys_values(line)
      if section
        @count_line[count] = section
      elsif key_val
        @count_line[count] = key_val
      end
      count += 1
    end
    @sections.each do |section|
      @sections_content[section] = []
    end
  end

  def get_value(section, key)
    @sections_content.each do |sect, content|
      if section == sect
        content.each do |topic|
          return convert(topic[key]) if topic[key]
        end
      end
    end
  end

  def convert(value)
    if value.match(/\d+/)
      value.to_i
    elsif value.match(/[0-9]+(\.[0-9]+)/)
      value.to_f
    else
      return value
    end
  end

  def get_sections(line)
    if line.include?("[")
      line = rid_white_spaces_sections(line)
      @sections << line
      return {"section" => line}
    end
  end


  def get_keys_values(line)
    if line.include?(":")
      key = line.split(":")[0]
      key = rid_white_spaces_quotes(key)
      value = line.split(":")[1]
      value = rid_white_spaces_values(value)
      value = rid_white_spaces_quotes(value)
      @keys_values[key] = value
      return {key => value}
    end

  end

  #REFACTOR!
  def create_section_content
    section_line_numbers = []
    @count_line.each do |count, content|
      content.each do |key, value|
        if key == "section"
          section_line_numbers << count
        end
      end
    end
    lines_sections = Hash[section_line_numbers.zip(@sections)]
    lines_sections.each do |line_number, section_title|
      @count_line.each do |count, content|
        if section_title == @sections[-1] && count > section_line_numbers[-1]
          @sections_content.values.last << content
        elsif section_line_numbers[section_line_numbers.index(line_number)+1]
          if count > line_number && count < section_line_numbers[section_line_numbers.index(line_number)+1]
            @sections_content[section_title] << content
          end
        end
      end
    end
  end
##################################
# Writing to a file
  def write
    File.open('test2.dos', 'w') { |file|
      @sections_content.each do |section, content|
        file << "[#{section}]\n\r"
        @sections_content[section].each do |content_hash|
          file << "#{content_hash}\n\r"
        end
      end
    }
      # file.write("your text") }
  end

  def add_colon(line)

  end






  private

  def rid_white_spaces_sections(line)
    line.gsub!(/\[/, "")
    line.gsub!(/\]/, "")
    return line.strip!
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

end

newbie = ParseFile.new('test.dos')
p newbie.sections_content
p newbie.get_value("header", "project")
p newbie.get_value("header", "budget")
p newbie.get_value("header", "accessed")
newbie.write


