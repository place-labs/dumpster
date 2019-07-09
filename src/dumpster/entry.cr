require "json"
require "./entry/*"

module Dumpster::Entry
  # Character offset for the start of the "type" field (for non-root entries).
  VT_START_POS = 37

  alias Types = Dumpster::Entry::Class | Dumpster::Entry::Object

  def self.from_json(line : String) : Types?
    entry = case line[VT_START_POS]
            when 'O' then Dumpster::Entry::Object
            when 'C' then Dumpster::Entry::Class
            else return
            end

    entry.from_json line
  end
end
