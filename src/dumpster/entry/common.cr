require "json"

# Common method and modules to be included in all entry structs.
module Dumpster::Entry::Common
  # Utility module for reading memory address fields.
  module Address
    extend self

    def from_s(string : String)
      string.to_u64 prefix: true
    end

    def to_s(value : UInt64)
      "0x#{value.to_s 16}"
    end

    def from_json(pull : JSON::PullParser)
      from_s pull.read_string
    end

    def to_json(value : UInt64, json : JSON::Builder)
      val = to_s value
      json.string val
    end
  end

   # See `Object#hash(hasher)`
  def hash(hasher)
    address.hash(hasher)
  end

  def ==(other : self)
    address == other.address
  end
end
