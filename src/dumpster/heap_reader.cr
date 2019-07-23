require "./entry"

# Reader for Ruby heap memory dumps collected from the ObjectSpace module.
#
# Stored dump files are in the http://jsonlines.org/ format. These can contain
# multiple gigabytes of data depending on the application being analysed. To
# reduce the resource overhead required to parse, HeapReader provides an
# efficient interface for iterating over these lazilly and emitting parsed
# structs.
class Dumpster::HeapReader
  include Iterator(Dumpster::Entry::EntryStruct)

  # IO containing the raw heap dump
  private getter io : IO

  # BufferedChannel of parsed heap objects ready to be emitted.
  private getter entries : Channel(Dumpster::Entry::EntryStruct)

  def initialize(@io, parsers = 16)
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

  # Spawn a fiber that will lazilly read from the wrapped `IO` and pipe lines
  # into a `BufferedChannel` of size *buffer_len*.
  private def spawn_line_reader(buffer_len)
    output_channel = Channel(String).new buffer_len

    spawn do
      io.each_line &->output_channel.send(String)
      output_channel.close
    end

    output_channel
  end

  # Spawn a set of *count* concurrent parsers and return a `BufferedChannel` of
  # entry structs.
  #
  # Each parser will pull lines from *input_channel*, parse these and pipe the
  # results into the returned channel.
  #
  # NOTE: parallel operations are not currently supported. This is
  # pre-emptively implemented to take advantage executation across a thread
  # pool when available. Based on current information this **should** work with
  # no / minimal changes, but might need some love at a future date.
  private def spawn_parsers(input_channel, count)
    output_channel = Channel(Entry::EntryStruct).new count

    count.times do
      spawn do
        begin
          loop do
            input_channel
              .receive
              .try(&->Entry.parse(String))
              .try(&->output_channel.send(Entry::EntryStruct))
          end
        rescue Channel::ClosedError
          # Nothing to do, one of the other fibers already finished the read.
        end

        output_channel.close
      end
    end

    output_channel
  end
end
