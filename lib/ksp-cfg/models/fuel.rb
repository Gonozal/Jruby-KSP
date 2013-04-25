module KspCfg
  module Models
    class Fuel
      attr_accessor :name, :density # Density: if you don't know what this is, dont play KSP
      attr_accessor :ppu # Price per unit
      attr_accessor :amount # amount of this type of fuel that is stored
    end
  end
end
