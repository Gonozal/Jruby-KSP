module KspCfg
  module Models
    class Propellant
      attr_accessor :name
      attr_accessor :amount # amount of this type of fuel that is stored
      attr_accessor :max_amount
      attr_accessor :ratio # usage ratio for engines
      attr_accessor :hash

      def initialize(hash)
        self.hash = hash
        return false unless valid_hash?
        set_attributes
      end

      def valid_hash?
        ((hash.has_key? :name and hash[:name].kind_of? String) and
          (hash.has_key? :ratio or hash.has_key? :maxAmount))
      end

      def set_attributes
        self.name = hash[:name]
        self.ratio = hash[:ratio] if hash.has_key? :ratio
        if hash.has_key? :maxAmount
          self.max_amount = hash[:maxAmount]
          self.amount = hash.has_key?(:amount)? hash[:amount] : 0
        end
      end

      def density
        { Kethane: 0.001, LiquidFuel: 0.005, XenonGas: 0.0001, SolidFuel: 0.0075,
          ElectricCharge: 0, IntakeAir: 0.005, Oxidizer: 0.005, MonoPropellant: 0.004,
          Water: 0.01, nuclearFuel: 0.0001, SpareParts: 1 }[name.to_sym]
      end

      def mass
        density * amount
      end

      def ppu
        { Kethane: 0.125, LiquidFuel: 4/9.to_f, XenonGas: 0.5, SolidFuel: 0.05,
          ElectricCharge: 0.5, IntakeAir: 0.0, Oxidizer: 1/6.to_f, MonoPropellant: 0.12,
          Water: 0.1, nuclearFuel: 0.1, SpareParts: 1 }[name.to_sym]
      end

      def self.from_hash_or_array(object)
        propellants = []
        if object.kind_of? Array
          object.each do |hash|
            propellants << Propellant.new(hash)
          end
        else
          propellants << Propellant.new(object)
        end
        propellants
      end
    end
  end
end
