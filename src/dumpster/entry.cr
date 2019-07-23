require "json"
require "./entry/*"

# Parser for building properly typed structs from ObjectSpace JSON dumps.
#
# See https://github.com/ruby/ruby/blob/01995df6453de45ba0d99835e26799260517657c/include/ruby/ruby.h#L486-L519
module Dumpster::Entry
  extend self

  # Character offset for the start of the "type" field (for non-root entries).
  VT_START_POS = 37

  # Union of parseable entry types.
  alias EntryStruct = Entry::Object |
                      Entry::Class |
                      Entry::Module |
                      Entry::Float |
                      Entry::String |
                      Entry::Regexp |
                      Entry::Array |
                      Entry::Hash |
                      Entry::Struct |
                      Entry::Bignum |
                      Entry::File |
                      Entry::Data |
                      Entry::Match |
                      Entry::Complex |
                      Entry::Rational

  # Parse an single line of a mem dump into its associated entry struct.
  def parse(line : ::String) : EntryStruct?
    type_of(line).try &.from_json(line)
  end

  # Infer the type of a line based on it's raw String form.
  def type_of(line : ::String)
    {% begin %}
      case line[VT_START_POS, 4]
      {% for t in EntryStruct.union_types %}
      when {{ t.name.split("::").last.upcase[0...4] }} then {{ t.id }}
      {% end %}
      end
    {% end %}
  end
end
