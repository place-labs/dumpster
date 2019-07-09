require "./base"

struct Dumpster::Entry::Object < Dumpster::Entry::Base
  JSON.mapping(
    address: { setter: false, type: UInt64, converter: Address                },
    klass:   { setter: false, type: UInt64, converter: Address, key: "class"  },
    file:    { setter: false, type: String?                                   },
    line:    { setter: false, type: UInt32?                                   },
    gen:     { setter: false, type: UInt32?                                   }
  )

  # Returns the location as "file:line" where this object was instantiated.
  def location
    "#{file}:#{line}" if file && line
  end
end
