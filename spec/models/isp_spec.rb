require_relative "../../lib/ksp-cfg"
require 'rspec'
require 'pp'

describe KspCfg::Models::Isp do

  let(:typical_isp_hash)        {{ key:  ["0 370", "1 320"] }}

  let(:vacuum_isp_hash)         {{ key: "0 370" }}

  let(:atmosphere_isp_hash)     {{ key: "1 320" }}

  let(:invalid_one)             {{ key: 0 }}
  let(:invalid_two)             {{ name: "something" }}

  describe "Typical Engines" do
    it "it loads a typical engine" do
      KspCfg::Models::Isp.new(typical_isp_hash).should be_true
    end

    it "loads correct values" do
      isp = KspCfg::Models::Isp.new(typical_isp_hash)
      isp.vacuum.should         eq(370)
      isp.atmosphere.should     eq(320)
    end
  end

  describe "Vacuum-only engines" do
    it "it loads vacuum-only engines" do
      isp = KspCfg::Models::Isp.new(vacuum_isp_hash)
      isp.valid?.should be_true
    end

    it "loads correct values" do
      isp = KspCfg::Models::Isp.new(vacuum_isp_hash)
      isp.vacuum.should         eq(370)
      isp.atmosphere.should     eq(370)
    end
  end

  describe "Atmosphere-only engines" do
    it "it loads atmosphere-only engines" do
      isp = KspCfg::Models::Isp.new(atmosphere_isp_hash)
      isp.valid?.should be_true
    end

    it "loads correct values" do
      isp = KspCfg::Models::Isp.new(atmosphere_isp_hash)
      isp.vacuum.should         eq(320)
      isp.atmosphere.should     eq(320)
    end
  end

  describe "Invalid engines" do
    it "it returns false for an invalid hash" do
      isp = KspCfg::Models::Isp.new(invalid_one)
      isp.valid?.should be_false
      isp = KspCfg::Models::Isp.new(invalid_two)
      isp.valid?.should be_false
    end
  end
end
