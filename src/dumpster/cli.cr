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
      Terminimal.exit_with_error "unkown option '#{flag}'", Errno::EINVAL.to_i
    end

    filename = ""
    opts.unknown_args do |args|
      filename = args.first? || Terminimal.exit_with_error "no FILE specified", Errno::EINVAL.to_i
      unless File.exists? filename
        Terminimal.exit_with_error "target FILE '#{filename}' does not exist", Errno::ENOENT.to_i
      end
    end

    opts.parse options

    Terminimal.cursor.hide

    File.open(filename) do |file|
      analyser = future { Analyser.parse file }

      Terminimal.spinner await: analyser do
        percent_read = ((file.pos.to_f / file.size) * 100).to_i
        "Reading heap dump (#{percent_read}%)"
      end
      heap = analyser.get
      print_heap_info heap

      puts

      locations = future { heap.locations_of_interest }
      Terminimal.spinner await: locations, message: "Analysing locations"

      puts "► Locations of interest"
      locations.get.each do |(name, location), growth|
        puts "#{sprintf "% 10.2f", growth}  #{location} (#{name})"
      end

      # print_table "Locations of interest", locations.get
    end
  end

  private def print_heap_info(heap : Analyser, io = STDOUT)
    io.puts <<-SUMMARY
    Parsed #{heap.object_count} objects
    Across #{heap.generation_count} generations
    SUMMARY
  end

  private def print_table(title : String, rows : Array(NamedTuple(T))) forall T
  end
end
