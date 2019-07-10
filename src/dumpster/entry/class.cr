require "./common"

struct Dumpster::Entry::Class
  include Common

  JSON.mapping(
    address: { setter: false, type: UInt64, converter: Address                },
    name:    { setter: false, type: String?                                   }
  )
end
