require "./base"

struct Dumpster::Entry::Class < Dumpster::Entry::Base
  JSON.mapping(
    address: { setter: false, type: UInt64, converter: Address                },
    name:    { setter: false, type: String                                    }
  )
end
