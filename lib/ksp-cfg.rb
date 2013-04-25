# require "java"
Dir["#{__dir__}/ksp-cfg/models/*.rb"].each do |file|
  require file
end

require "treetop"
require "polyglot"
require "#{__dir__}/ksp-cfg/treetop/cfg_parser"

module KspCfg
  def self.parse( path )
    Parser.new("src/parts/example.cfg")
  end
end
