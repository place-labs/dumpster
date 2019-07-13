require "../spec_helper"

macro describe_entry_type(type, line, test = ->(x) { })
  describe {{type}} do
    it "identifies the line type" do
      Dumpster::Entry.type_of({{line}}).should eq({{type}})
    end

    it "correctly parses into the associated struct" do
      parsed_entry = Dumpster::Entry.parse {{line}}

      fail "incorrect struct type" unless parsed_entry.is_a? {{type}}

      {{test}}.call(parsed_entry)
    end
  end
end

describe Dumpster::Entry do
  describe_entry_type(
    type: Dumpster::Entry::Object,
    line: "{\"address\":\"0x7fb4738140a0\", \"type\":\"OBJECT\", \"class\":\"0x7fb474ab84b8\", \"ivars\":6, \"file\":\"/foo/bar/example.rb\", \"line\":6, \"method\":\"load\", \"generation\":34, \"memsize\":88, \"flags\":{\"wb_protected\":true, \"old\":true, \"long_lived\":true, \"marked\":true}}",
    test: ->(entry : Dumpster::Entry::Object) do
      entry.address.should eq(0x7fb4738140a0)
      entry.class_address.should eq(0x7fb474ab84b8)
      entry.location.should eq("/foo/bar/example.rb:6")
      entry.generation.should eq(34)
    end
  )

  describe_entry_type(
    type: Dumpster::Entry::Class,
    line: "{\"address\":\"0x7fb473816e68\", \"type\":\"CLASS\", \"class\":\"0x7fb4740de410\", \"name\":\"Foo::Bar::Example\", \"references\":[\"0x7fb473816e90\", \"0x7fb4740de3c0\"], \"memsize\":712, \"flags\":{\"wb_protected\":true, \"old\":true, \"long_lived\":true, \"marked\":true}}",
    test: ->(entry : Dumpster::Entry::Class) do
      entry.address.should eq(0x7fb473816e68)
      entry.name.should eq("Foo::Bar::Example")
    end
  )
end
