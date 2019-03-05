require "json"

struct Dumpster::Object
  getter   address    : UInt64
  getter   type       : Type
  getter   class      : UInt64
  property file       : String?
  property line       : UInt32?
  property generation : UInt32?
  property memsize    : UInt32?
  property name       : String?

  def inititialize(@address, @type, @class)
  end

  # JSON.mapping(
  #   address: {type: UInt64, converter: MemAddressConverter},
  #   type: Type,
  #   class: {type: UInt64?, converter: MemAddressConverter},
  #   file: String?,
  #   line: Int32?,
  #   generation: Int32?,
  #   memsize: Int32,
  #   name: String? # Only in CLASS objects
  # )
  #
  # def self.preparse(line : String)
  #   new.tap do |o|
  #     o.address = address
  #     o.type    = object_type
  #     o.class   = object_class
  #   end
  # end
  #
  # module MemAddressConverter
  #   def self.from_json(pull : JSON::PullParser)
  #     pull.read_string.to_u64(prefix: true)
  #   end
  #
  #   def self.to_json(value : UInt64, json : JSON::Builder)
  #     json.string("0x#{value.to_s(16)}")
  #   end
  # end

  enum Type
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
