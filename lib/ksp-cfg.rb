# require "java"
require "parslet"

require_relative "ksp-cfg/models"
require_relative "ksp-cfg/parser"


module KspCfg
  def self.parse( path )
    Parser.new("src/parts/example.cfg")
  end
end
