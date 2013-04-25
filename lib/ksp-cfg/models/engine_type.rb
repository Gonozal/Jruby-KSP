module KspCfg
  class EngineType
    attr_accessor :name, :price_multiplier
    attr_accessor :isp_modifier # ISP that is substracted from engine ISP for calculation
  end
end
