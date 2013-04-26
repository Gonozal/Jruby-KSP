require_relative "../../lib/ksp-cfg"
require 'parslet/rig/rspec'
require 'parslet/convenience'
require 'pp'

describe KspCfg::Parser::Cfg do

  let(:parser) { KspCfg::Parser::Cfg.new }
  it "parses a pair" do
    parser.statement.should parse('some_key = some_value').as({
      key: 'some_key',
      value: { string: 'some_value' }
    })
  end

  it "parses a pair_list" do
    content = <<-EOT
      key1 = value1
      key2 = value2
    EOT
    parser.statements.should parse( content ).as([{
      key: 'key1',
      value: { string: 'value1' }
    }, {
      key: 'key2',
      value: { string: 'value2' }
    }])
  end

  it "parses a pair_list with whitespaces" do
    content = <<-EOT
      key1 = value1
      key2 = va lu e2
    EOT
    parser.statements.parse( content ).should == [ {
      key: 'key1',
      value: { string: 'value1' }
    }, {
      key: 'key2',
      value: { string: 'va lu e2' }
    }]
  end

  it "parses a float pair_list" do
    content = <<-EOT
      key1 = 12.5
      key2 = -12.5
    EOT
    parser.statements.should parse( content ).as([{
      key: 'key1',
      value: { float: '12.5' }
    }, {
      key: 'key2',
      value: { float: '-12.5' }
    }])
  end

  it "parses a boolean pair_list" do
    content = <<-EOT
      key1 = false
      key2 = True
    EOT
    parser.statements.parse( content ).should == [ {
      key: 'key1',
      value: { boolean: 'false' }
    }, {
      key: 'key2',
      value: { boolean: 'True' }
    }]
  end

  it "ignores commented lines inbetween" do
    content = <<-EOT
      key1 = value1
      // key1 = value1
      key2 = value2
    EOT
    parser.statements.parse( content ).should == [ {
      key: 'key1',
      value: { string: 'value1' }
    }, {
      key: 'key2',
      value: { string: 'value2' }
    }]
  end

  describe "blocks" do
    it 'parses a block name' do
      content = "  MODULE "
      parser.block_name.parse( content ).should == { block_name: "MODULE" }
    end

    it "parses a block" do
      content = <<-EOT
        MODULE
        {
          name = value1
          key2 = value2
        }
      EOT
      parser.block.parse( content ).should == {
        block_name: "MODULE",
        block: [
          {
            key: 'name',
            value: { string: 'value1' }
          }, {
            key: 'key2',
            value: { string: 'value2' }
          }
        ]
      }
    end

    it "parses nested blocks" do
      content = <<-EOT
        MODULE
        {
          name = value1
          PROPELLANT
          {
            name = kethane
          }
          key2 = value2
        }
      EOT
      pp parser.block.parse_with_debug( content )
      parser.block.parse( content ).should == {
        block_name: "MODULE",
        block: [
          {
            key: 'name',
            value: { string: 'value1' }
          },
          {
            key: 'key2',
            value: { string: 'value2' }
          }
        ]
      }
    end
  end
end

