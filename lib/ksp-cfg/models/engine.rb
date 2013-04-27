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
      end

      def valid_hash?
        required_keys = [:maxThrust, :PROPELLANT, :atmosphereCurve]
        required_keys.each do |required|
          return false unless hash.has_key? required
        end
        true
      end
    end
  end
end
