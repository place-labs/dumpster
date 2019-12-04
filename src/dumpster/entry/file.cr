require "./common"

struct Dumpster::Entry::File
  include Common

  JSON.mapping(
    address: {setter: false, type: UInt64, converter: Address},
    fd: {setting: false, type: UInt16?}
  )
end
