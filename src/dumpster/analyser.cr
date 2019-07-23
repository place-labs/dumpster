require "./heap_reader"

class Dumpster::Analyser
  private getter heap : HeapReader

  # Parses *io* and extracts analysis data.
  def self.parse(io)
    new(io).parse
  end

  private def initialize(io)
    @heap = HeapReader.new io
    @object_count = 0
    @classes = {} of UInt64 => String? # Address => Name
  end

  protected def parse
    heap.each do |entry|
      case entry
      when Dumpster::Entry::Object
        @object_count += 1
      when Dumpster::Entry::Class
        @classes[entry.address] = entry.name
      end

      Fiber.yield
    end
    self
  end

  # Gets the total number of objects parsed from the heap dump.
  getter object_count

  # Gets the total number of classes contained in the heap dump.
  def class_count
    # Duplicates may exist in mem from stale definitions - count via unique name
    @classes.invert.size
  end
end
