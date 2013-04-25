require_relative "../../lib/ksp-cfg"

describe KspCfg::Parser::Cfg do
  let(:parser) { KspCfg::Parser::Cfg.new }
  it "matches a pair" do
    parser.assignment_line.parse('some_key = some_value').should == {
      key: 'some_key',
      value: 'some_value'
    }
  end

  it "matches a pair_list" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = value1
      key2 = value2
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: 'value1'
    }, {
      key: 'key2',
      value: 'value2'
    }]
  end

  it "matches a pair_list with whitespaces" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = value1
      key2 = va lu e2
    EOT
    parser.assignments.parse( content ).should == [ {
      key: 'key1',
      value: 'value1'
    }, {
      key: 'key2',
      value: 'va lu e2'
    }]
  end


  it "ignores commented lines" do
    content = <<-EOT.gsub(/^ {6}/, '')
      // key1 = value1
      key2 = value2
    EOT
    parser.assignments.parse( content ).should == {
      key: 'key2',
      value: 'value2'
    }
  end
end
