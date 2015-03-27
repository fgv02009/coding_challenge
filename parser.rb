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
      key_val_cont = get_key_val_cont(line)
      if section
        @count_line[count] = section
      elsif key_val
        @count_line[count] = key_val
      elsif key_val_cont
        @count_line[count] = key_val_cont
      end
      count += 1
    end
    @sections.each do |section|
      @sections_content[section] = []
    end
    self.fix_cont_lines
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

  def get_key_val_cont(line)
    if line[0] == " "
      return {"cont" => line.strip!}
    end
  end

  def fix_cont_lines
    @sections_content.each do |section, array_key_values|
      counter = 1
      array_key_values.each_with_index do |hash, index|
        hash.each do |key, value|
          if key == "cont"
            previous_key = array_key_values[index-counter].keys[0]
            array_key_values[index-counter][previous_key] = array_key_values[index-counter][previous_key] + array_key_values[index][key]
            p index
            counter +=1
            # array_key_values.delete_at(index)
          end
        end
      end
      #Need to delete ones with "cont as key"
      # @sections_content.each do |section, array_key_values|
      #   array_key_values.select do |hash|
      #     p hash["cont"]
      #     if hash["cont"] == nil
      #     end
      #   end
      # end
    end
    p @sections_content
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
        check_length(content)
        file << "\n\r[#{section}]\n\r"
        @sections_content[section].each do |content_hash|
          file << "#{format_content_hash(content_hash)}\n\r"
        end
      end
    }
  end

  def format_content_hash(content)
    content = content.flatten
    content.join(":")
  end





########################


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
# p newbie.count_line
newbie.sections_content
newbie.fix_cont_lines
# newbie.write


