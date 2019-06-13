require "./version"
require "./parse"
require "option_parser"
require "colorize"

class Dumpster::Cli
  VERSION = "dumpster #{Dumpster::VERSION}"
  ABOUT   = "Analyse the contents of a Ruby MRI heap dumps."
  USAGE   = "Usage: dumpster [OPTION]... FILE"

  def self.run(options = ARGV)
    new(options).run
  end

  private getter options

  def initialize(@options : Array(String))
  end

  def run
    opt_parser = OptionParser.new

    opt_parser.banner = USAGE

    quick = false
    opt_parser.on("-q", "--quick", "Provide instance counts only.") do
      quick = true
    end

    opt_parser.on("-V", "--verion", "Show version information.") do
      print_and_exit VERSION
    end

    opt_parser.on("-h", "--help", "Print this help message.") do
      print_and_exit opt_parser, include_header: true
    end

    opt_parser.invalid_option do |opt|
      exit_with_error "unkown option '#{opt}'"
    end

    filename = "mem.dump"
    opt_parser.unknown_args do |args|
      case args.size
      when 1 then filename = args.first
      when 0 then exit_with_error "no dump file specified"
      else        exit_with_error "only one mem dump may be parsed at a time"
      end
    end

    opt_parser.parse options

    unless File.exists? filename
      exit_with_error "target FILE '#{filename}' does not exist"
    end

    print_heap_info filename, quick
  end

  private def print_heap_info(filename, quick = false)
    File.open(filename) do |file|
      heap = Dumpster::Parse.heap(file)
      puts heap[0x7fb47763fbb8]
    end
  end

  # Prints to STDOUT and exits
  private def print_and_exit(message, include_header = false, exit_code = 0)
    message = "#{VERSION}\n#{ABOUT}\n\n#{message}" if include_header
    STDOUT.puts message
    exit exit_code
  end

  # Prints to STDERR and exits
  private def exit_with_error(message, exit_code = 1)
    STDERR.puts "#{"error:".colorize.bright.red} #{message}"
    exit exit_code
  end
end
