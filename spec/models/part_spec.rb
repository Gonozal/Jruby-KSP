require_relative "../../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Models::Part do

  let(:file_path)             { "spec/fixtures/parts/example.cfg"}

  let(:part)                  { KspCfg::Models::Part.new(file_path) }

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
end
