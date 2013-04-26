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
  let(:assignment_sentence) { "name = some cool stuff" }
  let(:assignment_dots)     { "name = some.cool.stuff" }
  let(:value_list)          { "name = 12.5, 3" }
  let(:spaced_list)         { "key = 12 3" }
  let(:unspaced_value_list) { "name = 1,3,5,6,7" }
  let(:value_list_long )    { "name = 12.5,  3,  some_stuff, False" }

  # simple blocks
  let(:block_empty)         { "NAME_OF_BLOCK\n{\n}" }
  let(:block_assignment)    { "NAME_OF_BLOCK\n{\n#{assignment_pair}\n}" }

  # paired assignments
  let(:assignment_spaced)   { "\n\n key1 = value1   \n\n\n   key2   =   value2\n\n" }
  let(:assignment_pair)     { "key1 = value1\nkey2 = value2" }
  let(:block_pair)          { "key1 = value1\nkey2 = value2" }
  let(:document)            { 
  <<-EOT
    // Kerbal Space Program - Part Config
    // LV-T30 Liquid Fuel Engine
    // 

    // --- general parameters ---
    name = liquidEngine
    module = Part
    author = NovaSilisko

    // --- asset parameters ---
    mesh = model.mu
    scale = 0.1


    // --- node definitions ---
    node_stack_top = 0.0, 7.21461, 0.0, 0.0, 1.0, 0.0
    fx_exhaustSparks_flameout = 0.0, -10.3, 0.0, 0.0, 1.0, 0.0, flameout
    sound_vent_medium = engage
    sound_rocket_hard = running
    sound_vent_soft = disengage
    sound_explosion_low = flameout
    description = Although criticized by some due to its not unsignificant use of so-called "pieces found lying about", the LV-T series has proven itself as a comparatively reliable engine. The T30 model boasts a failure ratio below the 50% mark. This has been considered a major improvement over previous models by engineers and LV-T enthusiasts.
    // attachment rules: stack, srfAttach, allowStack, allowSrfAttach, allowCollision
    attachRules = 1,0,1,0,0
    stagingIcon = LIQUID_ENGINE

    attachRules = 1,0,1,0,0

    MODULE
    {
      name = ModuleEngines
      exhaustDamage = True
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
  EOT
  }

  # whitespace assignments

  describe :assignment do
    it "parses a string" do
      parser.assignment.should parse(assignment).as({
        key: 'name',
        value: { string: 'value' }
      })
    end

    it "parses a string with dots" do
      parser.assignment.should parse(assignment_dots).as({
        key: 'name',
        value: { string: 'some.cool.stuff' }
      })
    end

    it "parses a string with spaces" do
      parser.assignment.should parse(assignment_sentence).as({
        key: 'name',
        value: { string: 'some cool stuff' }
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

    it "parses a short value list" do
      parser.statements.should parse(value_list).as({
        key: 'name',
        value: [
          { float: "12.5" },
          { integer: "3" }
        ]
      })
    end

    it "parses a short space seperated list" do
      parser.statements.should parse(spaced_list).as({
        key: 'key',
        value: { string: "12 3"}
      })
    end

    it "parses a value list without spaces" do
      parser.statements.should parse(unspaced_value_list).as({
        key: 'name',
        value: [ 
          { integer: "1" },
          { integer: "3" },
          { integer: "5" },
          { integer: "6" },
          { integer: "7" }
        ]
      })
    end

    it "parses a long value list" do
      parser.statements.should parse(value_list_long).as({
        key: 'name',
        value: [
          { float: "12.5" },
          { integer: "3" },
          { string: "some_stuff" },
          { boolean: "False" }
        ]
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
    it "parses a single assignment" do
      parser.statements.should parse(assignment).as({
        key: 'name',
        value: { string: 'value' }
      })
    end

    it "parses a set of assignments" do
      parser.statements.should parse( assignment_pair ).as([{
        key: 'key1',
        value: { string: 'value1' }
      }, {
        key: 'key2',
        value: { string: 'value2' }
      }])
    end

    it "parses statements with whitespaces and newlines" do
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
  end

  describe :comments do
    it "parses commented at the beginning" do
      content = <<-EOT
        // key1 = value1
        key2 = value2
      EOT
      parser.statements.parse( content ).should == {
        key: 'key2',
        value: { string: 'value2' }
      }
    end

    it "parses inline comments" do
      commented_assignment = assignment + " // comment "
      parser.statements.parse( commented_assignment ).should == {
        key: 'name',
        value: { string: 'value' }
      }
    end

    it "parses multiple inline comments" do
      commented_assignment = assignment + " // comment \n"
      commented_assignment << assignment + " // comment "
      parser.statements.parse( commented_assignment ).should == [{
        key: 'name',
        value: { string: 'value' }
      },
      {
        key: 'name',
        value: { string: 'value' }
      }]
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
      parser.block_name.parse("  MODULE ").should == { block_name: "MODULE" }
    end

    it "parses an empty block" do
      parser.block.should parse( block_empty ).as({
        block_name: "NAME_OF_BLOCK",
        block: nil
      })
    end

    it "parses a block" do
      parser.block.should parse( block_assignment ).as({
        block_name: "NAME_OF_BLOCK",
        block: [
          {
            key: 'key1',
            value: { string: 'value1' }
          }, {
            key: 'key2',
            value: { string: 'value2' }
          }
        ]
      })
    end

    it "parses nested blocks" do
      content = %(MODULE
        {
          key1 = value1
          PROPELLANT
          {
            name = kethane
          }
          key2 = value2
        })
      parser.block.should parse( content ).as({
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
          #{block_assignment}
          #{block_assignment}
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
              key: 'key1',
              value: { string: 'value1' }
            }, {
              key: 'key2',
              value: { string: 'value2' }
            }]
          },
          {
            key: 'key2',
            value: { string: 'value2' }
          }
        ]
      })
    end
  end

  describe "document" do
    it "Does not fail parsing on a real document" do
      parser.statements.should_not be_nil
    end
  end
end
