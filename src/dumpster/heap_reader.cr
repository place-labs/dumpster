require "./object"

# Reader for Ruby heap memory dumps collected from the ObjectSpace module.
#
# Stored dump files are in the http://jsonlines.org/ format. These can contain
# multiple gigabytes of data depending on the application being analysed. To
# reduce the resource overhead required to parse these, HeapReader provides a
# an efficient method for enumerating individual entries as a stream.
class Dumpster::HeapReader
  include Enumerable(Dumpster::Object)

  # Character range containing the mem address within dump file lines.
  ADDRESS_POS = 12..25

  # Search string for marking the start of the value type definition.
  VT_SEARCH = "\", \"type\":\""

  # Terminator for value extractions.
  SEARCH_END = "\", \""

  private getter io
  private getter quick

  # TODO implemenent other filters
  def initialize(@io : IO, @quick = false)
  end

  def each
    entries = io.each_line chomp: false

    # Skip initial unaddressed ROOT objects
    entries = entries.skip_while { |line| line[2] != 'a' }

    entries.each do |line|
      if quick
        yield quick_parse(line)
      else
        yield parse(line)
      end
    end
  end

  private def quick_parse(line)
    address = line[ADDRESS_POS].to_u64 prefix: true

    vt_pos = line.index(VT_SEARCH, ADDRESS_POS.end)
    raise "unhandled entry format: \"#{line}\"" if vt_pos.nil?
    vt_pos += VT_SEARCH.size
    vt_end = line.index(SEARCH_END, vt_pos)
    raise "unhandled entry format: \"#{line}\"" if vt_end.nil?
    vt_len = vt_end - vt_pos
    value_type = Dumpster::Object::RubyVT.parse line[vt_pos, vt_len]

    Dumpster::Object.new(address, value_type)
  end

  private def parse(line)
    Dumpster::Object.from_json(line)
  end
end
