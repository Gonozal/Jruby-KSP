require_relative "../../lib/ksp-cfg"

describe KspCfg::Parser do
  it 'converts single line CFGs to a ruby hash' do
    KspCfg::Parser.parse('key = value').should == { 'key' => 'value' }
  end

  it 'converts multiple line CFGs to a ruby hash' do
    content = <<-EOT.gsub(/^ {4}/, '')
      key1 = value1
      key2 = value2
    EOT
    KspCfg::Parser.parse( content ).should == { 'key1' => 'value1', 'key2' => 'value2' }
  end
end
