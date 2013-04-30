Dir["#{File.dirname(__FILE__)}/models/*.rb"].each do |file|
  puts file
  require file
end
