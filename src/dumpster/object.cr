require "json"

# Reprentation of entities contained in Ruby MRI heap dumps.
struct Dumpster::Object
  JSON.mapping(
    address:    { setter: false, type: UInt64,  converter: Addr               },
    value_type: { setter: false, type: RubyVT,                   key: "type"  },
    klass:      { setter: false, type: UInt64?, converter: Addr, key: "class" },
    file:       { setter: false, type: String?                                },
    line:       { setter: false, type: UInt32?                                },
    generation: { setter: false, type: UInt32?                                },
    memsize:    { setter: false, type: UInt32?                                },
    name:       { setter: false, type: String?                                }
  )

  # See https://github.com/ruby/ruby/blob/7570864267cb258e2d29881e37cb3b8a6930727a/include/ruby/ruby.h#L485-L517
  enum RubyVT
    NONE

    OBJECT
    CLASS
    MODULE
    FLOAT
    STRING
    REGEXP
    ARRAY
    HASH
    STRUCT
    BIGNUM
    FILE
    DATA
    MATCH
    COMPLEX
    RATIONAL

    NIL
    TRUE
    FALSE
    SYMBOL
    FIXNUM
    UNDEF

    IMEMO
    NODE
    ICLASS
    ZOMBIE
  end

  module Addr
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

  def initialize(@address, @value_type, @klass = nil)
  end

   # See `Object#hash(hasher)`
  def hash(hasher)
    address.hash(hasher)
  end

  def ==(other : self)
    address == other.address
  end

  def location
    "#{file}:#{line}" if file && line
  end
end
