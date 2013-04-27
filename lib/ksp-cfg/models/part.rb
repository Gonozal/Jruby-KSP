module KspCfg
  module Models
    class Part
      attr_accessor :engine, :storage, :file_hash, :name
      def initialize(relative_path)
        self.file_hash = KspCfg::Parser::Parser.new.to_hash(relative_path)[:document]
        self.name = file_hash[:name]
        self.engine = []
        self.storage = []
      end

      # Tries to find all relevant data. Engines, resources etc
      def find_modules
        find_engine
        find_storage
      end

      def find_engine
        # only proceed if there are any modules
        return false unless file_hash.has_key? :MODULE
        if file_hash[:MODULE].kind_of? Array
          file_hash[:MODULE].each do |ksp_module|
            self.engine << Engine.new(ksp_module) if is_engine? ksp_module
          end
        else
          self.engine << Engine.new(file_hash[:MODULE]) if is_engine? file_hash[:MODULE]
        end
      end

      def is_engine?(hash)
        hash.has_key? :name and hash[:name] == "ModuleEngines"
      end

      def is_storage?(hash)
        hash.has_key? :name and Storage.allowed_resources.include? hash[:name]
      end
    end
  end
end
