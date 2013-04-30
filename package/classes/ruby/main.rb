begin
  require "java"
  require "gempack"
rescue Exception => e
  puts e
end
require "parslet"
require "pp"

require_relative "ksp-cfg"
require_relative "parser"
require_relative "models/engine"
require_relative "models/isp"
require_relative "models/part"
require_relative "models/propellant"
require_relative "parser/cfg"
require_relative "parser/transform"

parser = KspCfg::Init.new
parser.parse_all
