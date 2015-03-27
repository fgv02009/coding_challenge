require_relative 'parser2.rb'


describe ParseFile do
  let(:new_parser) {ParseFile.new('test.dos')}
  describe '#initialize' do
    it 'should set @file_str to an empty str' do
      expect(new_parser.file_str).to eq("")
    end
    it 'should set @file_name to the argument passed in' do
      expect(new_parser.file_name).to eq("test.dos")
    end
    it 'should set @section_content to an empty hash' do
      expect(new_parser.section_content).to eq({})
    end
    it 'should set @index_of_section_headers to an empty array' do
      expect(new_parser.index_of_section_headers).to eq([])
    end
    it 'should set @section to an empty array' do
      expect(new_parser.index_of_section_headers).to eq([])
    end
    it 'should set @file_arr to an empty array' do
      expect(new_parser.index_of_section_headers).to eq([])
    end
  end

  describe '#parse' do
    it 'should turn file string from an empty string to a concatonated string of the file, for parsing' do
      expect(new_parser.file_str).to eq("")
      new_parser.parse
      expect(new_parser.file_str).to eq("*[header] *project: Programming Test *budget : 4.5 *accessed :205  *[meta data] *description : This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind.  *correction text: I meant 'moderately,' not 'tediously,' above.  *[ trailer ] *budget:all out of budget. ")
    end

    it 'should call #set_section_content' do
      new_parser.should_receive(:set_section_content)
      new_parser.parse
    end

    # it 'should call #set_sections' do
    #   new_parser.should_receive(:set_sections)
    #   new_parser.parse
    # end

    it 'should call #fill_section_content' do
      new_parser.should_receive(:fill_section_content)
      new_parser.parse
    end
  end
  describe '#set_sections' do
  let(:parser3) {ParseFile.new('test.dos')}
    it 'should fill the instance variable @sections with the section titles from the file' do
      parser3.instance_variable_set("@section_content", {"start" =>[], "middle" => [], "end" =>[]})
      parser3.set_sections
      expect(parser3.sections).to eq(["start", "middle", "end"])
    end
  end

  describe '#get_value' do
    before do
      new_parser.parse
    end
    it 'takes a section and a key and returns the value in that section with that key as a string if it is a string' do
      expect(new_parser.get_value("header", "project")).to be_a_kind_of(String)
    end

    it 'takes a section and a key and returns the value in that section with that key as an Integer if it is an Integer' do
      expect(new_parser.get_value("header", "accessed")).to be_a_kind_of(Integer)
    end

    it 'takes a section and a key and returns the value in that section with that key as a Float if it is a Float' do
      expect(new_parser.get_value("header", "budget")).to be_a_kind_of(Float)
    end
    it 'takes a section and a key and returns the value in that section' do
      expect(new_parser.get_value("meta data", "description")).to eq("This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind.")
       expect(new_parser.get_value("header", "budget")).to eq(4.5)
       expect(new_parser.get_value("header", "accessed")).to eq(205)
    end
  end

  describe '#section_or_key?' do
    let (:line1) {"[section_title because I have brackets]"}
    let(:line2) {"key:value because I have a colon"}
    let(:line3) {"I don't contain a bracket or a colon so add_star should not be called"}
    it 'if a line from a file is a section header or a line that includes a key value, then it returns true' do
      expect(new_parser.section_or_key?(line1)).to be_truthy
      expect(new_parser.section_or_key?(line2)).to be_truthy
    end
     it 'if a line from a file is not a section header or a line that includes a key value, then it returns false' do
      expect(new_parser.section_or_key?(line3)).to be_falsey
    end
  end

  describe '#set_section_content' do
    let(:parser) {ParseFile.new('test.dos')}
    before do
      parser.instance_variable_set("@file_str", "*[header] *project: Programming Test *budget : 4.5 *accessed :205  *[meta data] *description : This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind.  *correction text: I meant 'moderately,' not 'tediously,' above.  *[ trailer ] *budget:all out of budget. ")
    end

    it 'changes @section_content from an empty hash to a hash with keys that are the section headers' do
      parser.set_section_content
      parser.section_content.each do |header, value|
        expect(["header", "meta data", "trailer"]).to include(header)
      end
    end
    it 'changes @section_content from an empty hash to a hash with values that are empty arrays' do
      parser.set_section_content
      parser.section_content.each do |header, value|
        expect(parser.section_content[header]).to be_kind_of(Array)
      end
    end
  end

  describe '#fill_section_content' do
    let(:parser) {ParseFile.new('test.dos')}
    before do
      parser.instance_variable_set("@index_of_section_headers", [1, 5, 8])
      parser.instance_variable_set("@sections", ["header", "meta data", "trailer"])
      parser.instance_variable_set("@file_arr", ["", "header", "project: Programming Test ", "budget : 4.5 ", "accessed :205  ", "meta data", "description : This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind.  ", "correction text: I meant 'moderately,' not 'tediously,' above.  ", "trailer", "budget:all out of money. "])
      parser.instance_variable_set("@section_content", {"header"=>[], "meta data"=>[], "trailer"=>[]})
    end
    it "fills section_content with the appropriate keys and values associated with each section header" do
      parser.fill_section_content
      expect(parser.section_content).to eq({"header"=>[{"project"=>"Programming Test"}, {"budget"=>"4.5"}, {"accessed"=>"205"}], "meta data"=>[{"description"=>"This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind."}, {"correction text"=>"I meant 'moderately,' not 'tediously,' above."}], "trailer"=>[{"budget"=>"all out of money."}]}
)
    end
  end

  describe '#split_line' do
    let(:content_hash) {{"description"=>"This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind."}}
    it 'should split a line into multiple lines based on how many times the length of that line is divisible by 60' do
      expect(new_parser.split_line(content_hash)).to eq("This is a tediously long description of the programming test\n\r that you are taking. Tedious isn't the right word, but it's\n\r the first word that comes to mind.")
    end
  end

  describe '#save' do
    before do
      new_parser.instance_variable_set("@section_content",
    {"header"=>[{"project"=>"Programming Test"}, {"budget"=>"4.5"}, {"accessed"=>"205"}, {"math"=>"fun"}], "meta data"=>[{"description"=>"This is a tediously long description of the programming test\n\r that you are taking. Tedious isn't the right word, but it's\n\r the first word that comes to mind."}, {"correction text"=>"I meant 'moderately,' not 'tediously,' above."}], "trailer"=>[{"budget"=>"all out of budget."}], "friends"=>[{"weekend"=>"dinner in downtown Chicago"}]})
    end
    it 'overwrites the file with what ever is in @section_content' do
      new_parser.save
      expect(File.read('test2.dos')).to include("dinner in downtown Chicago")
    end
  end

  describe '#write' do
    it 'allows you to write to the file if you pass it a section name that exist and a key value pair to add to that section' do
      new_parser.write("budget", "meeting", "all out of money")
      expect(File.read('test2.dos')).to include("meeting:all out of money")
    end
    it "allows you to write to the file if you pass it a section name that doesn't exist and a key value pair to add to that section" do
      new_parser.write("school", "classes", "set up study time")
      expect(File.read('test2.dos')).to include("[school]")
       expect(File.read('test2.dos')).to include("classes:set up study time")
      end

      it "calls #save" do
        new_parser.should_receive(:save)
        new_parser.write("school", "classes", "set up study time")
      end
  end
end

