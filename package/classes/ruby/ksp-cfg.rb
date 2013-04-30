module KspCfg
  class Init
    attr_accessor :dir_path, :backup_path, :stats
    def initialize
      begin
        dir_path = File.dirname(self.to_java.get_class().protection_domain().
                                code_source().location().path())
      rescue Exception => e
        dir_path = File.dirname(__FILE__)
      end
      self.dir_path = "#{dir_path.split("/")[0..-3].join("/")}/"
      self.stats = []
      prepare_backup
    end

    def parse_all
      path = "#{dir_path.split("/")[0..-2].join("/")}/Parts/*/"
      Dir[path].each do |dir|
        self.stats << parse("#{dir}part.cfg")
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

    def parse( path )
      begin
        part = Models::Part.new(absolute: path)
        part.find_modules
        old_cost = part.file_hash[:cost]
        new_cost = part.cost
        if (part.engine.any? or part.storage.any? or part.command_mod > 0) and
          new_cost > 20
          if old_cost != new_cost
            puts "Parsed #{part.name}. Cost was changed from #{old_cost} to #{new_cost}"
            backup(path: File.dirname(path).split("/").last, part: part)
            File.open(path, 'w') do |f|
              content = part.parser.file_content
              f.write(content.gsub(/cost = (\d*)/, "cost = #{new_cost.to_s}"))
            end
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

    def prepare_backup
      time = Time.new.strftime "%Y-%m-%d_%H-%M-%S"
      puts "Creating backup dir in backup/#{time}"
      self.backup_path = "#{dir_path}backup/#{time}"
      Dir.mkdir("#{dir_path}backup") unless Dir.exists? "#{dir_path}backup"
      Dir.mkdir(backup_path)
    end

    def backup( params )
      path = "#{backup_path}/#{params[:path]}/"
      Dir.mkdir(path)
      File.open("#{path}part.cfg", 'w') {|f| f.write(params[:part].parser.file_content) }
    end
  end
end
