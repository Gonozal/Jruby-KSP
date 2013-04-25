require_relative "../../lib/ksp-cfg"

describe KspCfg::Parser::Cfg do
  let(:parser) { KspCfg::Parser::Cfg.new }
  it "matches a key" do
    parser.key.parse('some_key =').should == { key: 'some_key' }
  end

  it "matches a value" do
    parser.value.parse('some_crazy_value').should == { value: 'some_crazy_value' }
  end

  it "matches a pair" do
    parser.pair.parse('some_key = some_value').should == {
      key: 'some_key',
      value: 'some_value'
    }
  end

  it "matches a pair_list" do
    content = <<-EOT.gsub(/^ {6}/, '')
      key1 = value1
      key2 = value2
    EOT
    parser.pair_list.parse( content ).should == [ {
      key: 'key1',
      value: 'value1'
    }, {
      key: 'key2',
      value: 'value2'
    }]
  end
end
