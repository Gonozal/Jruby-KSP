require_relative "../../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Models::Part do

  let(:file_path)             { "spec/fixtures/parts/example.cfg"}
  let(:mengine_path)             { "spec/fixtures/parts/mengine.cfg"}

  let(:part)                  { KspCfg::Models::Part.new(file_path) }
  let(:mengine)                  { KspCfg::Models::Part.new(mengine_path) }

  let(:engine_hash)         { { name: "ModuleEngines", exhaustDamage: true, ignitionThreshold: 0.1, minThrust: 0, heatProduction: 400, fxOffset: [0, 0, 0.8], PROPELLANT: { name: "LiquidFuel", ratio: 0.9, DrawGauge: true }, atmosphereCurve: { key:  ["0 370", "1 320"] } } }
  let(:invalid_engine_hash) { { name: "ModuleAlternator", exhaustDamage: true, minThrust: 0, PROPELLANT: { name: "LiquidFuel", DrawGauge: true } } }

  let(:resource_hash)       { { name: "LiquidFuel", amount: 810, maxAmount: 810 } }
  let(:invalid_resource_hash) { { name: "LiquidNitrogen", amount: 200, maxAmount: 200 } }


  describe :load do
    it "can identify a correct engine hash" do
      part.is_engine?(engine_hash).should be_true
    end

    it "can identify a wrong engine hash" do
      part.is_engine?(invalid_engine_hash).should be_false
      part.is_engine?(resource_hash).should be_false
      part.is_engine?(invalid_resource_hash).should be_false
    end

    it "can identify a correct resource hash" do
      part.is_storage?(resource_hash).should be_true
    end

    it "can identify a wong resource hash" do
      part.is_storage?(invalid_resource_hash).should be_false
      part.is_storage?(engine_hash).should be_false
    end
  end

  describe "example engine part" do
    it "parses it correctly" do
      part.find_modules
      part.engine.first.should be_kind_of(KspCfg::Models::Engine)
      part.engine.size.should eq(1)
      part.storage.size.should eq(0)
      part.cost.should be_between(650, 850)
    end
  end

  describe "KW Rocketry engine part" do
    it "parses it correctly" do
      mengine.find_modules
      mengine.engine.first.should be_kind_of(KspCfg::Models::Engine)
      mengine.engine.size.should eq(1)
      mengine.storage.size.should eq(1)
      mengine.cost.should be_between(650, 900)
    end
  end

  describe "example storage part" do
    it "parses it correctly" do
      part2 = KspCfg::Models::Part.new("spec/fixtures/parts/storage_example.cfg")
      part2.find_modules
      part2.engine.size.should eq(0)
      part2.storage.size.should eq(2)
      part2.storage.first.should be_kind_of(KspCfg::Models::Propellant)
      part2.mass_ratio.should eq(9)
      part2.adjusted_mass_ratio.should eq(2)
      part2.mass.should eq(4)
      part2.cost.should be_between(7000, 9000)
    end
  end
end
