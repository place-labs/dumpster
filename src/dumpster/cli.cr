require "./version"
require "./analyser"
require "terminimal"
require "option_parser"
require "errno"

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
      puts VERSION
      exit
    end

    opts.on("-h", "--help", "Print this help message.") do
      puts VERSION
      puts ABOUT
      puts
      puts opts
      exit
    end

    opts.invalid_option do |flag|
      Terminimal.exit_with_error "unkown option '#{flag}'", Errno::EINVAL
    end

    filename = ""
    opts.unknown_args do |args|
      filename = args.first? || Terminimal.exit_with_error "no FILE specified", Errno::EINVAL
      unless File.exists? filename
        Terminimal.exit_with_error "target FILE '#{filename}' does not exist", Errno::ENOENT
      end
    end

    opts.parse options

    Terminimal.cursor.hide

    File.open(filename) do |file|
      analyser = future { Analyser.parse file }

      Terminimal.spinner await: analyser do
        percent_read = ((file.pos.to_f / file.size) * 100).to_i
        "Analysing (#{percent_read}%)"
      end

      print_heap_info analyser.get
    end
  end

  private def print_heap_info(heap : Analyser, io = STDOUT)
    io.puts <<-SUMMARY
    Found #{heap.object_count} objects
    Built from #{heap.class_count} classes
    Using #{heap.object_memsize >> 20}MiB of memory
    SUMMARY
  end
end
