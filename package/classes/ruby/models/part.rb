module KspCfg
  module Models
    class Part
      attr_accessor :engine, :storage, :file_hash, :name, :mass, :command_mod
      def initialize(path = {})
        self.file_hash = KspCfg::Parser::Parser.new.to_hash(path)[:document]
        self.name = file_hash[:name]
        self.mass = file_hash[:mass] if file_hash.has_key? :mass
        self.engine = []
        self.storage = []
        self.command_mod = 0
      end

      # Tries to find all relevant data. Engines, resources etc
      def find_modules
        find_engine
        find_storage
        find_pod
      end

      def find_pod
        self.command_mod += file_hash[:CrewCapacity] if file_hash.has_key? :CrewCapacity
        return false unless file_hash.has_key? :MODULE
        if file_hash[:MODULE].kind_of? Array
          file_hash[:MODULE].each do |ksp_module|
            self.command_mod += 2 if is_command? ksp_module
          end
        else
          self.command_mod += 2 if is_command? file_hash[:MODULE]
        end
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

      def find_storage
        return false unless file_hash.has_key? :RESOURCE
        resources = file_hash[:RESOURCE]
        if resources.kind_of? Array
          resources.each do |resource|
            self.storage << Propellant.new(resource) if is_storage? resource
          end
        else
          self.storage << Propellant.new(resources) if is_storage? resources
        end
      end

      def mass_ratio
        m = 0
        storage.each do |s|
          m += s.mass
        end
        (mass + m) / mass
      end

      def adjusted_mass_ratio
        [1.5, mass_ratio - 7, 5].sort[1]
      end

      def cost
        c = 0
        # Engine Costs
        engine.each do |e|
          c += e.cost
        end
        # Storage Costs
        storage.each do |s|
          c += s.cost(adjusted_mass_ratio)
        end
        # Command-Pod Costs
        c += command_mod * 500
        c.round(-1)
      end

      def is_engine?(hash)
        hash.has_key? :name and hash[:name] == "ModuleEngines"
      end

      def is_command?(hash)
        hash.has_key? :name and hash[:name] == "ModuleCommand"
      end

      def is_storage?(hash)
        hash.has_key? :name and Propellant.allowed_resources.include? hash[:name]
      end
    end
  end
end
