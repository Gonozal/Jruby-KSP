require_relative "../../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Models::Engine do

  let(:engine_hash) {{
    name: "ModuleEngines",
    minThrust: 0,
    maxThrust: 480,
    PROPELLANT: [{
      name: "LiquidFuel",
      ratio: 0.9,
      DrawGauge: true
    }, {
      name: "Oxidizer",
      ratio: 1.1
    }],
    atmosphereCurve: {
      key:  ["0 370", "1 320"]
    }
  }}

  let(:mono_engine) {{ name: "ModuleEngines", minThrust: 0, maxThrust: 480, PROPELLANT: { name: "MonoPropellant", ratio: 1, DrawGauge: true }, atmosphereCurve: { key:  ["0 370", "1 320"] } }}

  let(:jet_engine) {{ name: "ModuleEngines", minThrust: 0, maxThrust: 480, PROPELLANT: [{ name: "LiquidFuel", ratio: 1, DrawGauge: true }, { name: "IntakeAir", ratio: 1.1 }], atmosphereCurve: { key:  ["0 370", "1 320"] } }}

  let(:solid_engine) {{ name: "ModuleEngines", minThrust: 0, maxThrust: 100, PROPELLANT: { name: "SolidFuel", ratio: 1 }, atmosphereCurve: { key:  ["0 250", "1 230"] } }}

  let(:ion_engine) {{ name: "ModuleEngines", minThrust: 0, maxThrust: 480, PROPELLANT: [{ name: "ElectricCharge", ratio: 12.0 }, { name: "XenonGas", ratio: 0.1 }], atmosphereCurve: { key:  ["0 4200"] } }}


  let(:kethane_engine) {{ name: "ModuleEngines", minThrust: 0, maxThrust: 480, PROPELLANT: [{ name: "Kethane", ratio: 1, DrawGauge: true }, { name: "KIntakeAir", ratio: 15 }], atmosphereCurve: { key:  ["0 370", "0.45 1900", "1 320"] } }}



  let(:engine)                  { KspCfg::Models::Engine.new(engine_hash) }

  describe :initialize do
    it "parses the engine power" do
      engine.power.should   eq(480)
    end

    it "parses needed propellants" do
      engine.propellants.count.should eq(2)
      engine.propellants.should be_kind_of(Array)
      engine.propellants.each do |propellant|
        propellant.should be_kind_of(KspCfg::Models::Propellant)
        propellant.name.should be_kind_of(String)
        propellant.ratio.should be_kind_of(Float)
      end
    end

    it "parses ISP values" do
      engine.isp.vacuum.should eq(370)
      engine.isp.atmosphere.should eq(320)
    end

    it "guesses the right type" do
      engine.type.should eq(:liquid)
      engine2 = KspCfg::Models::Engine.new(ion_engine)
      engine2.type.should eq(:ion)
      engine2 = KspCfg::Models::Engine.new(kethane_engine)
      engine2.type.should eq(:kethane)
      engine2 = KspCfg::Models::Engine.new(solid_engine)
      engine2.type.should eq(:solid)
      engine2 = KspCfg::Models::Engine.new(jet_engine)
      engine2.type.should eq(:jet)
      engine2 = KspCfg::Models::Engine.new(mono_engine)
      engine2.type.should eq(:mono)
    end
  end
end
