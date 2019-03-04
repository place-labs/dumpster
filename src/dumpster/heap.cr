module Dumpster; end

class Dumpster::Heap
  def initialize(mem_dump : IO)
    # Lazy eval
    entries = mem_dump.each_line

    non_root_entries = entries.skip_while { |line| line[2] != 'a' }

    objects = non_root_entries.map { |line| HeapObject.from_json(line) }

    objects.first(10).each do |obj|
      puts obj
    end
  end

  def []=(address : Int64)

  end

  def [](address : Int64) : ObjectRef

  end
end
