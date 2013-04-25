require "java"
require "json"
require_relative "models/engine"
require_relative "models/engine_type"
require_relative "models/isp"
require_relative "models/storage"
require_relative "models/fuel"
require_relative "models/parser"
require "treetop"
require "polyglot"
require_relative "treetop/cfg_parser"


Parser.new("src/parts/example.cfg")
