require "./common"

struct Dumpster::Entry::Regexp
  include Common

  JSON.mapping(
    address: {setter: false, type: UInt64, converter: Address}
  )
end
