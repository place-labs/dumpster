require "json"
require "./entry/*"

module Dumpster::Entry
  # Character offset for the start of the "type" field (for non-root entries).
  VT_START_POS = 37

  # Union of parseable entry types.
  alias Types = Entry::Object |
                Entry::Class

  # Parse an single line of a mem dump into its associated entry struct.
  def self.parse(line : String) : Types?
    type_of(line).try &.from_json(line)
  end

  # Infer the type of a line based on it's raw String form.
  def self.type_of(line : String)
    case line[VT_START_POS]
    when 'O' then Entry::Object
    when 'C' then Entry::Class
    end
  end
end
