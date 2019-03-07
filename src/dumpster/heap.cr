require "./object"

alias Address = UInt64

class Dumpster::Heap
  include Enumerable({Address, Dumpster::Object})

  @objects = {} of Address => Dumpster::Object

  # Pull an object based on it's memory address.
  def [](address)
    @objects[address]
  end

  # Add an object to the heap
  def <<(object)
    @objects[object.address] = object
    self
  end

  # Provide an iterator for each object on the heap.
  def each
    @objects.each_value
  end

  # Number of objects contained within the heap.
  def object_count
    @objects.size
  end

  # Provide a list of the top class addresses based on instance count.
  def top_objects_by_count(count = 20)
    reduce(counter) { |instances, o| instances[o.klass] += 1 }
      .to_a
      .sort_by!(&:last)
      .last(count)
  end

  # Convenience method for creating a hash that counts attribues against a
  # memory object.
  private def counter
    Hash(Address, Int32).new { |h, k| h[k] = 0 }
  end
end
