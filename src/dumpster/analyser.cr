require "./heap_reader"
require "./num_tools"

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

    # Address => Name
    @classes = {} of UInt64 => String?

    # Autoviv stats counters
    @location_counts = Hash(Generation, LocationCounter).new do |h, gen|
      h[gen] = LocationCounter.new { |h, k| h[k] = 0 }
    end
    @instance_counts = Hash(Generation, InstanceCounter).new do |h, gen|
      h[gen] = InstanceCounter.new { |h, k| h[k] = 0 }
    end
  end

  protected def parse
    heap.each do |entry|
      @object_count += 1

      generation = entry.generation || 0_u32
      object_type = entry.type

      case entry
      when Dumpster::Entry::Object
        class_name = @classes[entry.class_address]?
        object_type = class_name unless class_name.nil?
      when Dumpster::Entry::Class
        @classes[entry.address] = entry.name
      end

      # Associate entries by generation and form counts of the points of
      # instantiation (locations) and instance types created (instances).

      if entry.responds_to?(:location)
        location = entry.location
        unless location.nil?
          @location_counts[generation][{object_type, location}] += 1
        end
      end

      @instance_counts[generation][object_type] += 1

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
    @instance_counts.size
  end

  # Find the the locations associated with the highest positive rate of change
  # of object instances.
  def locations_of_interst(count = 20)
    locations = Set.new @location_counts.values.flat_map(&.keys)

    gradient = {} of typeof(locations.first) => Float64

    locations.each do |location|
      # Get the number of new instantiations for each generation
      instantiations = @location_counts.values.map { |gen| gen[location] }

      # Map to the total active objects at each generation
      counts = instantiations.accumulate

      # TODO: find the slope of the linear regression - maybe LAPACK?

      gradient[location] = 0.0
    end

    # gradient.sort_by(&.last).first(count)
  end

  def types_of_interest

  end
end
