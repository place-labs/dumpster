require "./entry"

# Reader for Ruby heap memory dumps collected from the ObjectSpace module.
#
# Stored dump files are in the http://jsonlines.org/ format. These can contain
# multiple gigabytes of data depending on the application being analysed. To
# reduce the resource overhead required to parse, HeapReader provides a an
# efficient interface for iterating over these lazilly an emitting
class Dumpster::HeapReader
  include Iterable(Dumpster::Entry::Types)

  private getter io

  def initialize(@io : IO)
  end

  # Perform a single pass across the IO, emitting entries as they are parsed.
  def each
    io.each_line.compact_map(&->Dumpster::Entry.from_json(String))
  end
end
