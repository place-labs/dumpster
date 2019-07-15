require "./version"
require "./analyser"
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

    # quick = false
    # opts.on("-q", "--quick", "Provide instance counts only.") do
    #   quick = true
    # end

    opts.on("-V", "--verion", "Show version information.") do
      print_and_exit VERSION
    end

    opts.on("-h", "--help", "Print this help message.") do
      print_and_exit opts, include_header: true
    end

    opts.invalid_option do |flag|
      exit_with_error "unkown option '#{flag}'", exit_code: 22
    end

    filename = ""
    opts.unknown_args do |args|
      filename = args.first? || exit_with_error "no FILE specified", exit_code: 22
      unless File.exists? filename
        exit_with_error "target FILE '#{filename}' does not exist", exit_code: 2
      end
    end

    opts.parse options

    File.open(filename) do |file|
      analyser = Analyser.parse file
      print_heap_info analyser

      # entries = file.each_line
      #
      # entries.first(10).each do |entry|
      #   puts file.pos
      #   puts entry
      # end
    end
  end

  private def print_heap_info(heap : Analyser, io = STDOUT)
    io.puts <<-SUMMARY
    Found #{heap.object_count} objects
    Built from #{heap.class_count} classes
    Using #{heap.object_memsize >> 20}MiB of memory
    SUMMARY
  end

  # Prints to STDOUT and exits
  private def print_and_exit(message, include_header = false) : NoReturn
    message = "#{VERSION}\n#{ABOUT}\n\n#{message}" if include_header
    STDOUT.puts message
    exit
  end

  # Prints to STDERR and exits
  private def exit_with_error(message, exit_code) : NoReturn
    STDERR.puts "#{"error:".colorize.bright.red} #{message}"
    exit exit_code
  end
end
