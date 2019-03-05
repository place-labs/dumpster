require "./heap/*"

class Dumpster::Heap
  def initialize(@mem_dump : IO)
  end

  def [](address : UInt64) : Dumpster::Heap::Object

  end
end
