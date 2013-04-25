# require "java"
Dir["ksp-cfg/models/*.rb"].each {|file| require file }

require "treetop"
require "polyglot"
require_relative "ksp-dfg/treetop/cfg_parser"


Parser.new("src/parts/example.cfg")
