require_relative "../../lib/ksp-cfg"
require 'parslet/rig/rspec'
require 'parslet/convenience'
require 'pp'

describe KspCfg::Parser::Cfg do

  let(:parser)              { KspCfg::Parser::Cfg.new }

  # basic assignments
  let(:assignment)          { "name = value" }
  let(:assignment_int)      { "name = 20" }
  let(:assignment_bool)     { "name = true" }
  let(:assignment_float)    { "name = -20.5" }
  let(:assignment_sentence) { "name = value" }

  # simple blocks
  let(:block_empty)         { "NAME_OF_BLOCK\n{\n}" }
  let(:block_assignment)    { "NAME_OF_BLOCK\n{\nname=value\n}" }

  # paired assignments
  let(:assignment_pair)     { "key1 = value1\nkey2 = value2" }
  let(:block_pair)          { "key1 = value1\nkey2 = value2" }

  describe :assignment do
    it "parses a string" do
      parser.assignment.should parse(assignment).as({
        key: 'name',
        value: { string: 'value' }
      })
    end

    it "parses an integer" do
      parser.assignment.should parse(assignment_int).as({
        key: 'name',
        value: { integer: '20' }
      })
    end

    it "parses a float" do
      parser.assignment.should parse(assignment_float).as({
        key: 'name',
        value: { float: '-20.5' }
      })
    end

    it "parses a boolean value" do
      parser.assignment.should parse(assignment_bool).as({
        key: 'name',
        value: { boolean: 'true' }
      })
    end
  end

  describe :statement do
    it "parses a pair" do
      parser.statement.should parse(assignment).as({
        key: 'name',
        value: { string: 'value' }
      })
    end
    it "parses an empty block" do
      parser.statement.should parse(block_empty).as({
        block_name: 'NAME_OF_BLOCK',
        block: nil
      })
    end
  end

  describe :statements do
    it "parses a single statement" do
      parser.statement.should parse('some_key = some_value').as({
        key: 'some_key',
        value: { string: 'some_value' }
      })
    end

    it "parses a set of assignments" do
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

    it "can handle multiple newlines" do
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

    it "parses statements with whitespaces" do
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

    it "parses a float set" do
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

    it "parses a boolean set" do
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
  end

  describe "comments" do
    it "ignores commented at the beginning" do
      content = <<-EOT
        // key1 = value1
        key2 = value2
      EOT
      parser.statements.parse( content ).should == {
        key: 'key2',
        value: { string: 'value2' }
      }
    end

    it "ignores a whole lot of comments all over the pace" do
      content = <<-EOT
        // key1 = value1
        // key1 = value1
        // key1 = value1
        // key1 = value1
        // key1 = value1
        key2 = value2
        // key1 = value1
        // key1 = value1
        // key1 = value1
      EOT
      parser.statements.parse( content ).should == {
        key: 'key2',
        value: { string: 'value2' }
      }
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
      parser.statements.should parse( content ).as({
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
      })
    end

    it "parses nested blocks" do
      content = <<-EOT
        MODULE
        {
          key1 = value1
          PROPELLANT
          {
            name = kethane
          }
          key2 = value2
        }
      EOT
      parser.statements.should parse( content ).as({
        block_name: "MODULE",
        block: [
          {
            key: 'key1',
            value: { string: 'value1' }
          },
          {
            block_name: 'PROPELLANT',
            block: {
              key: 'name',
              value: { string: 'kethane' }
            }
          },
          {
            key: 'key2',
            value: { string: 'value2' }
          }
        ]
      })
    end

    it "parses multiple nested blocks with the same name" do
      content = <<-EOT
        MODULE
        {
          key1 = value1
          PROPELLANT
          {
            name = kethane
          }
          PROPELLANT
          {
            name = kethane
          }
          key2 = value2
        }
      EOT
      parser.statements.should parse( content ).as({
        block_name: "MODULE",
        block: [
          {
            key: 'key1',
            value: { string: 'value1' }
          },
          {
            block_name: 'PROPELLANT',
            block: {
              key: 'name',
              value: { string: 'kethane' }
            }
          },
          {
            block_name: 'PROPELLANT',
            block: {
              key: 'name',
              value: { string: 'kethane' }
            }
          },
          {
            key: 'key2',
            value: { string: 'value2' }
          }
        ]
      })
    end
  end
end

