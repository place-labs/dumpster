require "./common"

struct Dumpster::Entry::Object
  include Common

  JSON.mapping(
    address: {setter: false, type: UInt64, converter: Address},
    class_address: {setter: false, type: UInt64, converter: Address, key: "class"},
    file: {setter: false, type: String?},
    line: {setter: false, type: UInt32?},
    generation: {setter: false, type: UInt32?}
  )

  # Returns the location as "file:line" where this object was instantiated.
  def location
    "#{file}:#{line}" if file && line
  end
end
