require "./entry"

# Reader for Ruby heap memory dumps collected from the ObjectSpace module.
#
# Stored dump files are in the http://jsonlines.org/ format. These can contain
# multiple gigabytes of data depending on the application being analysed. To
# reduce the resource overhead required to parse, HeapReader provides an
# efficient interface for iterating over these lazilly and emitting parsed
# structs.
class Dumpster::HeapReader
  include Iterator(Dumpster::Entry::Types)

  # IO containing the raw heap dump
  private getter io : IO

  # BufferedChannel of parsed heap objects ready to be emitted.
  private getter entries : Channel(Dumpster::Entry::Types)

  def initialize(@io, @parsers = 32)
    lines = spawn_line_reader parsers * 2
    @entries = spawn_parsers lines, parsers
  end

  # See `Iterator#next`
  def next
    if entries.closed? && entries.empty?
      stop
    else
      entries.receive
    end
  end

  # See `Iterator#rewind`
  def rewind
    io.rewind
  end

  # Spawn a fiber that will read from the wrapped IO and pipe lines into the
  # returned channel.
  private def spawn_line_reader(buffer_len)
    output_channel = Channel(String).new buffer_len

    spawn do
      io.each_line &->output_channel.send(String)
      output_channel.close
    end

    output_channel
  end

  # Spawn a set of `count` fibers. Each of these will pull lines from
  # `input_channel`, parse them and pipe into the returned channel.
  private def spawn_parsers(input_channel, count)
    output_channel = Channel(Dumpster::Entry::Types).new count

    count.times do
      spawn do
        until input_channel.closed? && input_channel.empty?
          begin
            line  = input_channel.receive
            entry = Dumpster::Entry.parse line
            output_channel.send entry unless entry.nil?
          rescue Channel::ClosedError
            # Nothing to do, one of the other fibers already finished the read.
          end
        end
        output_channel.close
      end
    end

    output_channel
  end
end
