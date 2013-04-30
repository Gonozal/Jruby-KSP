require "java"
require "parslet"
require "pp"
require_relative "ksp-cfg"

require_relative "ksp-cfg/models"
require_relative "ksp-cfg/parser"
KspCfg.parse_all
