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
    opts = OptionParser.new

    opts.banner = USAGE

    quick = false
    opts.on("-q", "--quick", "Provide instance counts only.") do
      quick = true
    end

    opts.on("-V", "--verion", "Show version information.") do
      print_and_exit VERSION
    end

    opts.on("-h", "--help", "Print this help message.") do
      print_and_exit opts, include_header: true
    end

    opts.invalid_option do |flag|
      exit_with_error "unkown option '#{flag}'"
    end

    filename = "mem.dump"
    opts.unknown_args do |args|
      filename = args.first? || exit_with_error "no FILE specified"
    end

    opts.parse options

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
