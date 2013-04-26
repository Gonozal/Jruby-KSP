require_relative "../../lib/ksp-cfg"
require 'parslet/rig/rspec'
require 'parslet/convenience'
require 'pp'

describe KspCfg::Parser::Transform do
  let(:xform)               { KspCfg::Parser::Transform.new }

  # Data Types
  let(:integer)             { { integer: "1" } }
  let(:float)               { { float: "0.123" } }
  let(:boolean)             { { boolean: "True" } }
  let(:string)              { { string: "Some awesome text goes here" } }

  # Hashes
  let(:basic_hash)          { { key: "some", value: { string: "thing" } } }
  let(:integer_array)       { { value: [{ integer: 3 }, { integer: 5 }] } }
  let(:nested_array)        { {
    value: [
      { value: [{ integer: 3 }, { integer: 5 }] },
      { value: [{ string: "something" }, { boolean: "true" }] }
    ]
  }}

  let(:simple_block)        { {
    block_name: "MODULE",
    block: {
      key: 'key1',
      value: { string: 'value1' }
    }
  }}

  let(:nested_block)        { {
    block_name: "MODULE",
    block: [
      {
        key: 'key0',
        value: { string: 'value0' }
      },
      {
        block_name: 'NAME_OF_BLOCK',
        block: [{
          key: 'key1',
          value: { string: 'value1' }
        }, {
          key: 'key2',
          value: { string: 'value2' }
        }]
      },
      {
        block_name: 'NAME_OF_BLOCK',
        block: [{
          key: 'key3',
          value: { string: 'value3' }
        }, {
          key: 'key4',
          value: { string: 'value4' }
        }]
      },
      {
        key: 'key5',
        value: { string: 'value5' }
      }
    ]
  }}


  context "Data Types" do
    it "Parses integers" do
      xform.apply(integer).should eq(1)
    end

    it "Parses floats" do
      xform.apply(float).should eq(0.123)
    end

    it "Parses booleans" do
      xform.apply(boolean).should eq(true)
    end

    it "Parses strings" do
      xform.apply(string).should eq("Some awesome text goes here")
    end
  end

  context "Hashes" do
    it "Transforms basic hashes into key-value pairs" do
      xform.apply(basic_hash).should eq({ some: "thing" })
    end

    it "Transforms an array of integers" do
      xform.apply(integer_array).should eq([3, 5])
    end

    it "Transforms an array of integers" do
      xform.apply(nested_array).should eq([[3, 5], ["something", true]])
    end
  end

  context "Block" do
    it "Transforms a simple block into a hash" do
      xform.apply(simple_block).should eq({
        MODULE: { key1: "value1" }
      })
    end

    it "Transforms a nested block into a hash" do
      xform.apply(nested_block).should eq({
        MODULE: { 
          key0: "value0",
          NAME_OF_BLOCK: [{
            key1: "value1",
            key2: "value2"
          }, {
            key3: "value3",
            key4: "value4"
          }],
          key5: "value5"
        }
      })
    end
  end
end
