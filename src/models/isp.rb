module KspCfg
  module Models
    class Isp
      attr_accessor :atmosphere, :vacuum
      attr_accessor :atmosphere_math, :vacuum_math
      def initialize(hash)
        set_attributes(hash)
      end

      def valid?
        return (!!self.vacuum and !!self.atmosphere)
      end

      def set_attributes(hash)
        return false unless hash.has_key? :key
        if hash[:key].kind_of? Array
          hash[:key].each do |curve|
            curve_to_values(curve)
          end
        else
          curve_to_values(hash[:key])
        end
        self.vacuum ||= atmosphere
        self.atmosphere ||= vacuum
      end

      def curve_to_values(curve)
        return false unless curve.kind_of? String
        atoms = curve.split
        case atoms.first
        when "0" then self.vacuum = atoms[1].to_i
        when "1" then self.atmosphere = atoms[1].to_i
        end
      end

      def isp_adjustment
        {
          liquid: 220,
          solid: 180,
          ion: 350,
          jet: 220,
          kethane: 180,
          mono: 100,
          other: 150
        }
      end

      def adjust_for_type(type)
        self.atmosphere_math = atmosphere - isp_adjustment[type]
        self.vacuum_math = vacuum - isp_adjustment[type]
      end

      def cost_multiplier(type)
        adjust_for_type(type)
        atmosphere_math * vacuum_math
      end
    end
  end
end
