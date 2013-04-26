Dir["#{__dir__}/parser/*.rb"].each do |file|
  require file
end

module KspCfg
  module Parser
    def self.parse_file(relative_path)
      File.open(path, "r+").each do |line|
        file_content << line
      end

      cfg_parser = CfgParser.new
      cfg_parser.parse(file_content)
    end

    def self.parse( str )
      parser = Cfg.new
      result = parser.parse( str )
      result
    end
  end

  class ParserException < Exception
    def initialize( msg, line, column )
      super( "Error: #{msg} (at line #{line}, column #{column})" )
    end
  end
end
