module KspCfg
  module Models
    class Storage
      attr_accessor :fuel

      def self.allowed_resources
        [ "LiquidFuel", "SolidFuel", "Oxidizer", "XenonGas", "ElectricCharge", "Kethane" ]
      end
    end
  end
end
