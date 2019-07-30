require "../spec_helper"

describe Dumpster::Counter do
  counter = Dumpster::Counter(Symbol).new

  it "returns a 0 count when unpopulated" do
    counter.count(:Foo).should eq(0)
  end

  it "support incrementation" do
    counter.count(:Bar).should eq(0)
    counter.increment :Bar
    counter.count(:Bar).should eq(1)
  end
end
