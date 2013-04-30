require "java"
require "parslet"
require "pp"

require_relative "ksp-cfg/models"
require_relative "ksp-cfg/parser"


module KspCfg
  def self.parse_all
    dir_path = File.dirname(__FILE__)
    path = "#{dir_path}/../../Parts/*/"
    stats = []
    Dir[path].each do |dir|
      stats << parse("#{dir}part.cfg")
    end
    successes = stats.inject(0){ |s, e| e.has_key?(:success)? s += 1 : s}
    failures = stats.inject(0){ |s, e| e.has_key?(:error)? s += 1 : s }
    puts "parsed #{stats.count - failures} of #{stats.count} parts successfully"
    puts "#{successes} prices have been changed"
    puts "#{failures} parts failed to be parsed:"
    stats.each do |stat|
      if stat.has_key? :error
        puts "Failed to parse #{stat[:path]}: "
        puts stat[:error].message
      end
    end
  end

  def self.parse( path )
    begin
      part = Models::Part.new(absolute: path)
      part.find_modules
      old_cost = part.file_hash[:cost]
      new_cost = part.cost
      if (part.engine.any? or part.storage.any? or part.command_mod > 0) and part.cost > 20
        if old_cost == new_cost
          puts "Parsed #{part.name}. Cost was changed from #{old_cost} to #{new_cost}"
        else
          puts "Parsed #{part.name}. Cost was not changed"
        end
        return {success: part}
      else
        return {nothing: part}
      end
    rescue Exception => e
      return {error: e, path: path}
    end
  end
end
