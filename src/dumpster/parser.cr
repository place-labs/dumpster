module Dumpster::Parser
  extend self

  def partial_object(line : String) : Dumpster::Object
  end

  def object(line : String) : Dumpster::Object
  end
end
