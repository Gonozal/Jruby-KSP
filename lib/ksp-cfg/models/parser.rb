module KspCfg
  class Parser
    def initialize(relative_path)
      file_content = read_file(relative_path)

      cfg_parser = CfgParserParser.new
      cfg_parser.parse(file_content).resolve
    end

    def self.parse( str )
      parser = CfgParserParser.new
      result = parser.parse( str )
      if !result
        raise ParserException.new( parser.failure_reason, parser.failure_line, parser.failure_column )
      end
      result.resolve
    end

    def read_file(path)
      File.open(path, "r+").each do |line|
        self.file_content << line
      end
      file_content
    end
  end

  class ParserException < Exception
    def initialize( msg, line, column )
      super( "Error: #{msg} (at line #{line}, column #{column})" )
    end
  end
end
