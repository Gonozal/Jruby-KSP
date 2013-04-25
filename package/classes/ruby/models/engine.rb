class Engine
  attr_accessor :isp, :power

end

class Isp
  attr_accessor :atmosphere, :vacuum

end

class EngineType
  attr_accessor :name, :price_multiplier
  attr_accessor :isp_modifier # ISP that is substracted from engine ISP for calculation
end
