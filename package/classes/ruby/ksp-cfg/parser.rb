Dir["#{File.dirname(__FILE__)}/parser/*.rb"].each do |file|
  require file
end

module KspCfg
  module Parser
    class Parser
      attr_accessor :file_content, :parsed_file, :transformed_file
      def initialize
        self.file_content = ""
      end

      def load_file(path = {})
        path[:absolute] = path[:relative] if path.has_key? :relative
        File.open(path[:absolute], "r+").each do |line|
          self.file_content << line
        end
        file_content
      end

      def parse
        parser = Cfg.new
        self.parsed_file = parser.document.parse(file_content)
      end

      def transform
        transformer = Transform.new
        self.transformed_file = transformer.apply(parsed_file)
      end

      def to_hash(relative_path)
        if relative_path.kind_of? Hash
          load_file(relative_path)
        else
          load_file(relative: relative_path)
        end
        parse
        transform
      end
    end

    class ParserException < Exception
      def initialize( msg, line, column )
        super( "Error: #{msg} (at line #{line}, column #{column})" )
      end
    end
  end
end
