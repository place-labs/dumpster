require "json"

struct Dumpster::HeapObject
  JSON.mapping(
    address: {type: UInt64, converter: MemAddressConverter},
    type: ObjectType,
    class: {type: UInt64?, converter: MemAddressConverter},
    file: String?,
    line: Int32?,
    generation: Int32?,
    memsize: Int32,
    name: String? # Only in CLASS objects
  )

  module MemAddressConverter
    def self.from_json(pull : JSON::PullParser)
      pull.read_string.to_u64(prefix: true)
    end

    def self.to_json(value : UInt64, json : JSON::Builder)
      json.string("0x#{value.to_s(16)}")
    end
  end

  enum ObjectType
    ARRAY
    BIGNUM
    CLASS
    COMPLEX
    DATA
    FILE
    FLOAT
    HASH
    ICLASS
    MATCH
    MODULE
    NODE
    OBJECT
    REGEXP
    RATIONAL
    ROOT
    STRING
    STRUCT
    SYMBOL
  end

  def hash
    address
  end

  def instantiated_at
    "#{file}:#{line}" if file && line
  end
end
