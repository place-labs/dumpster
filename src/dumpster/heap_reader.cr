# Pre-parser for Ruby heap memory dumps collected from the ObjectSpace module.
#
# Stored dump files are in the http://jsonlines.org/ format. These can contain
# multiple gigabytes of data depending on the application being analysed. To
# reduce the resource overhead required to parse these HeapReader provides a
# an efficient method for memory addresses to their raw entries for lazy
# parsing as required.
class Dumpster::HeapReader
  # Character range containing the mem address within dump file lines.
  ADDRESS = 12..25

  alias Address  = UInt64
  # FIXME: File::PReader does not currently support 64bit addresses. Underlying
  # syscall does appear to though - may need to submit a PR.
  alias Offset   = Int32 #| Int64
  alias Length   = Int32
  alias Location = {Offset, Length}

  # Given an IO containing a Ruby memory dump, build a map relating object
  # addresses to the byte offset containing the object details.
  #
  # OPTIMIZE: replace with a Boyer-Moore search for address entries to find
  # offsets then calculate length on extraction only
  # TODO: change to tuple with type and class extracted too
  def self.map(io : IO) : Hash(Address, Location)
      entries = io.each_line chomp: false

      # Skip initial unaddressed ROOT objects
      entries = entries.skip_while { |line| line[2] != 'a' }

      entries.reduce({} of Address => Location) do |map, line|
        address = line[ADDRESS].to_u64(prefix: true)
        length  = line.bytesize
        offset  = io.pos - length
        map[address] = {offset.to_i32, length}
        map
      end
  end

  def initialize(@io : IO)
    @entries = HeapReader.map @io
  end

  def [](address)
    entry = @entries[address]
    @io.read_at(*entry) { |io| io.gets_to_end }
  end
end
