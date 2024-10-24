require "./common"
require "json_mapping"

struct Dumpster::Entry::Array
  include Common

  JSON.mapping(
    address: {setter: false, type: UInt64, converter: Address},
    file: {setter: false, type: ::String?},
    line: {setter: false, type: UInt32?},
    generation: {setter: false, type: UInt32?}
  )

  # Returns the location as "file:line" where this instance was instantiated.
  def location
    "#{file}:#{line}" if file && line
  end
end
