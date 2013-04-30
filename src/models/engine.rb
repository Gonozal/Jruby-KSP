module KspCfg
  module Models
    class Engine
      attr_accessor :isp, :propellants, :power, :hash, :type
      def initialize(hash)
        self.hash = hash
        return false unless valid_hash?
        set_attributes
      end

      def set_attributes
        self.power = hash[:maxThrust]
        self.isp = Isp.new(hash[:atmosphereCurve])
        self.propellants = Propellant.from_hash_or_array(hash[:PROPELLANT])
        self.type = get_type
      end

      def power_multiplier
        if power > 10
          power / Math.log(power, 10)
        else
          power
        end
      end

      def cost_multiplier
        return 1 if type == nil
        {
          liquid: 1,
          solid: 0.8,
          kethane: 0.14,
          jet: 0.11,
          ion: 0.75,
          mono: 0.5,
          other: 1
        }[type]
      end

      def get_type
        names = propellants.inject([]) { |a, e| a << e.name }

        liquid_propellants = [ "LiquidFuel", "Oxidizer" ]
        jet_propellants = [ "LiquidFuel", "IntakeAir" ]
        solid_propellants = [ "SolidFuel" ]
        ion_propellants = [ "XenonGas" , "ElectricCharge" ]
        kethane_propellants = [ "Kethane", "KIntakeAir" ]
        mono_propellants = [ "MonoPropellant" ]

        if (names - liquid_propellants).size == 0
          :liquid
        elsif (names - ion_propellants).size == 0
          :ion
        elsif (names - jet_propellants).size == 0
          :jet
        elsif (names - solid_propellants).size == 0
          :solid
        elsif (names - kethane_propellants).size == 0
          :kethane
        elsif (names - mono_propellants).size == 0
          :mono
        else
          :other
        end
      end

      def cost
        isp.cost_multiplier(type) * cost_multiplier * power_multiplier / 1000
      end

      def valid_hash?
        return false unless hash.kind_of? Hash
        required_keys = [:maxThrust, :PROPELLANT, :atmosphereCurve]
        required_keys.each do |required|
          return false unless hash.has_key? required
        end
        true
      end
    end
  end
end
