class Parser
  attr_accessor :file_content
  def initialize(relative_path)
    self.file_content = ""
    read_file(relative_path)

    cfg_parser = CfgParserParser.new
    puts cfg_parser.parse(file_content).resolve
  end


  def read_file(path)
    File.open(path, "r+").each do |line|
      self.file_content << line
    end
    file_content
  end

  def parse

  end
end
