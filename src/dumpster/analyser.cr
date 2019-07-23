require "./heap_reader"

class Dumpster::Analyser
  private getter heap : HeapReader

  # Parses *io* and extracts analysis data.
  def self.parse(io)
    new(io).parse
  end

  # {type, location} => count
  alias LocationCounter = Hash({::String, ::String}, UInt64)

  # type => count
  alias InstanceCounter = Hash(::String, UInt64)

  alias Generation = UInt32

  alias GenerationStats = Hash(Generation, {LocationCounter, InstanceCounter})

  private def initialize(io)
    @heap = HeapReader.new io
    @object_count = 0
    @classes = {} of UInt64 => String? # Address => Name
    @stats = GenerationStats.new do |stats, gen|
      stats[gen] = {
        LocationCounter.new { |h, k| h[k] = 0 },
        InstanceCounter.new { |h, k| h[k] = 0 }
      }
    end
  end

  protected def parse
    heap.each do |entry|
      @object_count += 1

      object_type = entry.type

      case entry
      when Dumpster::Entry::Object
        class_name = @classes[entry.class_address]?
        object_type = class_name unless class_name.nil?
      when Dumpster::Entry::Class
        @classes[entry.address] = entry.name
      end

      locations, instances = @stats[entry.generation || 0_u32]

      if entry.responds_to?(:location)
        location = entry.location
        unless location.nil?
          locations[{object_type, location}] += 1
        end
      end

      instances[object_type] += 1

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

  def generation_count
    @stats.size
  end
end
