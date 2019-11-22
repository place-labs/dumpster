require "./heap_reader"
require "./num_tools"
require "./counter"

class Dumpster::Analyser
  private getter heap : HeapReader

  # Parses *io* and extracts analysis data.
  def self.parse(io)
    new(io).parse
  end

  # Keyed on {type, location}
  alias LocationCounter = Counter({::String, ::String})

  # Keyed on type
  alias InstanceCounter = Counter(::String)

  alias Generation = UInt32

  private def initialize(io)
    @heap = HeapReader.new io

    @object_count = 0

    # Address => Name
    @classes = {} of UInt64 => String?

    # Stats counters for tracking points of interest across each GC generation
    @location_counts = [] of LocationCounter
    @instance_counts = [] of InstanceCounter
  end

  # Creates a `Hash` that will autopopulate elements with zero type, or new
  # instance of the appropropriate value type when first accessed.
  macro autoviv_hash(key_type, value_type)
    Hash({{key_type}}, {{value_type}}).new do |h, k|
      {% if value_type.resolve.class.has_method?(:zero) %}
        h[k] = {{value_type}}.zero
      {% else %}
        h[k] = {{value_type}}.new
      {% end %}
    end
  end

  # Perform a single pass across the dump file and count points of interest
  # across generations.
  protected def parse
    location_counts = autoviv_hash(Generation, LocationCounter)
    instance_counts = autoviv_hash(Generation, InstanceCounter)

    heap.each do |entry|
      @object_count += 1

      generation = entry.generation || Generation.zero
      object_type = entry.type

      case entry
      when Dumpster::Entry::Object
        # FIXME: object names may not be resolved at this point, may need to
        # initially store with address, then perform name resolution as a
        # second pass.
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
          location_counts[generation].increment({object_type, location})
        end
      end

      instance_counts[generation].increment object_type

      Fiber.yield
    end

    # Extract generation based counters and discard absolute generation numbers
    @location_counts = location_counts.values
    @instance_counts = instance_counts.values

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
  def locations_of_interst(limit = 100, min_instances = 100, min_slope = 1e-3)
    counters = @location_counts

    # Build a set of all known locations of object instantiation.
    # NOTE: the rather obtuse syntax is intentional to enable lazy iteration
    # while building the set.
    locations = Set.new counters.each.flat_map(&.each.map { |(k, _)| k })

    # List of locations of potential interest
    growing = [] of {location: typeof(locations.first), gradient: Float64, instance: Array(UInt32)}

    locations.each do |location|
      # Build a series with cumulative instance counts at each GC generation.
      counts = counters.map(&.count location)
      instance = counts.cumsum

      # Ignore items with low total instance count
      next unless instance.last > min_instances

      # Fit a linear regression to the cumulative instance count
      _, gradient = NumTools.linreg(instance.map_with_index { |y, x| {x, y} })

      next if gradient < min_slope

      # TODO: ignore items with a poor fit

      growing << {
        location: location,
        gradient: gradient,
        instance: instance,
      }

      Fiber.yield
    end

    # TODO: calculate pearson correlation and filter for strong positive (> 0.5)

    correlations = NumTools.correlate growing.map { |x| x[:instance] }

    # FIXME: Supremely inefficient transformations, optimise at will.
    zips = growing.map(&.[:location]).zip(correlations.to_aa)
    values = zips.select do |l, correlation|
      correlation.any? { |c| c > 0.5 }
    end

    values.map_with_index do |(v, c), idx|
      {v, growing[idx][:gradient]}
    end.sort_by!(&.last)
  end

  def types_of_interest
  end
end
