require_relative "../../lib/ksp-cfg"

describe KspCfg::Parser::Cfg do
  let(:parser) { KspCfg::Parser::Cfg.new }
  it "matches a pair" do
    parser.assignment_line.parse('some_key = some_value').should == {
      key: 'some_key',
      value: { string: 'some_value' }
    }
  end

  it "matches a pair_list" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = value1
      key2 = value2
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: { string: 'value1' }
    }, {
      key: 'key2',
      value: { string: 'value2' }
    }]
  end

  it "matches a pair_list with whitespaces" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = value1
      key2 = va lu e2
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: { string: 'value1' }
    }, {
      key: 'key2',
      value: { string: 'va lu e2' }
    }]
  end

  it "matches a float pair_list" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = 12.5
      key2 = -12.5
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: { float: '12.5' }
    }, {
      key: 'key2',
      value: { float: '-12.5' }
    }]
  end

  it "matches a boolean pair_list" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = false
      key2 = True
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: { boolean: 'false' }
    }, {
      key: 'key2',
      value: { boolean: 'True' }
    }]
  end

  it "ignores commented lines inbetween" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = value1
      // key1 = value1
      key2 = value2
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: { string: 'value1' }
    }, {
      key: 'key2',
      value: { string: 'value2' }
    }]
  end


  it "parses a block" do
    content = <<-EOT.gsub(/^ {6}/, '')
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


  it "parses a block" do
    content = <<-EOT.gsub(/^ {6}/, '')
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
