require_relative "../../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Models::Engine do

  let(:engine_hash)         {{
    name: "ModuleEngines",
    exhaustDamage: true,
    ignitionThreshold: 0.1,
    minThrust: 0,
    maxThrust: 480,
    heatProduction: 400,
    fxOffset: [0, 0, 0.8],
    PROPELLANT: {
      name: "LiquidFuel",
      ratio: 0.9,
      DrawGauge: true
    },
    PROPELLANT: {
      name: "Oxidizer",
      ratio: 1.1
    },
    atmosphereCurve: {
      key:  ["0 370", "1 320"]
    }
  }}

  let(:engine)                  { KspCfg::Models::Engine.new(engine_hash) }

  describe :load do
    it "read the engine power" do
      engine.power.should   eq(480)
    end
  end
end
