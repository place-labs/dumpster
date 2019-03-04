require "./dumpster/*"
require "option_parser"

include Dumpster

OptionParser.parse! do |parser|
  parser.on("-d FILE", "--dump-file FILE", "Ruby heap dump file") do |path|
    File.open(path) do |file|
      heap = Heap.new(file)
    end
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end
