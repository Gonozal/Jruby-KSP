require_relative "../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Parser::Parser do

  let(:parser)                { KspCfg::Parser::Parser.new }

  let(:mengine_path)          { "spec/fixtures/parts/mengine.cfg" }

  let(:file_path)             { "spec/fixtures/parts/example.cfg"}
  let(:file_content)          {
  <<-EOT
name = liquidEngine
// --- node definitions ---
node_stack_top = 0.0, 7.21461, 0.0, 1.0
mass = 3
description = Although criticized by some 
MODULE
{
	name = ModuleEngines
	exhaustDamage = True
	ignitionThreshold = 0.1
	minThrust = 0
	maxThrust = 100
	heatProduction = 400
	fxOffset = 0, 0, 0.8
	PROPELLANT
	{
		name = LiquidFuel
    ratio = 0.9
		DrawGauge = True
	}
	PROPELLANT
	{
		name = Oxidizer
    ratio = 1.1
	}
	atmosphereCurve
 	{
   	 key = 0 370
  	 key = 1 320
 	}
}
MODULE
{
    name = ModuleAnimateHeat
}
  EOT
  }

  let(:file_transformed)           { {
    document: {
      name: "liquidEngine",
      node_stack_top: [0.0, 7.21461, 0.0, 1.0],
      mass: 3,
      description: "Although criticized by some",
      MODULE: [ {
        name: "ModuleEngines",
        exhaustDamage: true,
        ignitionThreshold: 0.1,
        minThrust: 0,
        maxThrust: 100,
        heatProduction: 400,
        fxOffset: [0, 0, 0.8],
        PROPELLANT: [
          {
            name: "LiquidFuel",
            ratio: 0.9,
            DrawGauge: true
          }, {
            name: "Oxidizer",
            ratio: 1.1
          }
        ],
        atmosphereCurve: {
          key:  ["0 370", "1 320"]
        }
      }, {
        name: "ModuleAnimateHeat"
      } ]
    }
  }}

  describe :file do
    it "can load a file correctly" do
      parser.load_file(relative: file_path).should eq(file_content)
    end

    it "can load an KW Rocketry engine file correctly" do
      parser.load_file(relative: mengine_path)
      parser.parse
      parser.transform.should_not be_nil
    end

    it "sets file_content attribute correctly" do
      parser.load_file(relative: file_path)
      parser.file_content.should eq(file_content)
    end

    it "parses a loaded file" do
      parser.file_content = file_content
      parser.parse
      parser.transform.should eq(file_transformed)
    end

    it "can do it all in one step" do
      parser.to_hash(file_path).should eq(file_transformed)
    end
  end
end
