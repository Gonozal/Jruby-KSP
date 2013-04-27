Dir["#{__dir__}/models/*.rb"].each do |file|
  puts file
  require file
end
