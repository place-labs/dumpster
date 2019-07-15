require "./heap_reader"

class Dumpster::Analyser
  private getter heap : HeapReader

  # Parses *io* and extracts analysis data.
  def self.parse(io)
    new(io).tap &.parse
  end

  private def initialize(io)
    @heap = HeapReader.new io

    @num_of_objects = 0
    @classes = {} of UInt64 => Entry::Class
  end

  protected def parse
    heap.each do |entry|
      case entry
      when Dumpster::Entry::Object
        @num_of_objects += 1
      when Dumpster::Entry::Class
        @classes[entry.address] = entry
      else
        raise "Unhandled entry type"
      end
    end
  end

  # Gets the total number of objects contained in the heap dump.
  getter num_of_objects

  # Gets the total number of classes contained in the heap dump.
  def num_of_classes
    @classes.size
  end
end
