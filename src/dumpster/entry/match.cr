require "./common"

struct Dumpster::Entry::Match
  include Common

  JSON.mapping(
    address: {setter: false, type: UInt64, converter: Address}
  )
end
