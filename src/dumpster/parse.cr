require "./object"
require "./heap"

module Dumpster::Parse
  extend self

  def object(line : String) : Dumpster::Object
    Dumpster::Object.from_json(line)
  end

  # Perform a fast partial parse based on direct string extraction.
  #
  # This creates a instances with fields at static offset values only (address,
  # type, class) and may be used for pre-parsing or situations where speed is
  # required over completeness.
  def partial_object(line : String) : Dumpster::Object
    # TODO perform index based extract (use Addr.from_s)
  end

  def heap(io : IO)
    io.each_line
      .skip_while { |line| line[2] != 'a' }
      .map(&->Dumpster::Object.from_json(String))
      .reduce(Dumpster::Heap.new) { |heap, object| heap << object }
  end

  def partial_heap(io : IO)
    # Build io_map and partial objects
    # Parse full class objects
  end
end
