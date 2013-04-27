require_relative "../../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Models::Propellant do

  let(:first_propellant_hash)  {{ name: "ElectricCharge", ratio: 12.0 }}
  let(:second_propellant_hash) {{ name: "XenonGas", ratio: 0.1 }}
  let(:third_propellant_hash)  {{ name: "Oxidizer", ratio: 1.1 }}

  let(:first_resource_hash)    {{ name: "ElectricCharge", amount: 0, maxAmount: 0 }}
  let(:second_resource_hash)   {{ name: "LiquidFuel", amount: 810, maxAmount: 810 }}
  let(:third_resource_hash)    {{ name: "Oxidizer", amount: 0, maxAmount: 990 }}

  let(:invalid_one)            {{ name: "Some name", amount: 0 }}
  let(:invalid_two)            {{ propellant: { name: "XenonGas", ratio: 0.1 } }}

  describe "propellants" do
    it "loads typical hashes" do
      KspCfg::Models::Propellant.new(first_propellant_hash).should be_true
    end

    it "loads correct values" do
      propellant = KspCfg::Models::Propellant.new(first_propellant_hash)
      propellant.name.should            eq("ElectricCharge")
      propellant.ratio.should           eq(12.0)

      propellant = KspCfg::Models::Propellant.new(second_propellant_hash)
      propellant.name.should            eq("XenonGas")
      propellant.ratio.should           eq(0.1)

      propellant = KspCfg::Models::Propellant.new(third_propellant_hash)
      propellant.name.should            eq("Oxidizer")
      propellant.ratio.should           eq(1.1)
    end
  end

  describe "resources" do
    it "loads typical hashes" do
      KspCfg::Models::Propellant.new(first_resource_hash).should be_true
    end

    it "loads correct values" do
      propellant = KspCfg::Models::Propellant.new(first_resource_hash)
      propellant.name.should            eq("ElectricCharge")
      propellant.amount.should          eq(0)
      propellant.max_amount.should      eq(0)
      propellant.ppu.should             eq(0.5)
      propellant.density.should         eq(0)
      propellant.mass.should            eq(0)

      propellant = KspCfg::Models::Propellant.new(second_resource_hash)
      propellant.name.should            eq("LiquidFuel")
      propellant.amount.should          eq(810)
      propellant.max_amount.should      eq(810)
      propellant.ppu.should             eq(4/9.to_f)
      propellant.density.should         eq(0.005)
      propellant.mass.should            eq(4.05)

      propellant = KspCfg::Models::Propellant.new(third_resource_hash)
      propellant.name.should            eq("Oxidizer")
      propellant.amount.should          eq(0)
      propellant.max_amount.should      eq(990)
      propellant.ppu.should             eq(1/6.to_f)
      propellant.density.should         eq(0.005)
      propellant.mass.should            eq(0.0)
    end
  end

  describe "invalid hashes" do
    it "does not produce errors" do
      KspCfg::Models::Propellant.new(invalid_one)
      KspCfg::Models::Propellant.new(invalid_two)
    end
  end
end
