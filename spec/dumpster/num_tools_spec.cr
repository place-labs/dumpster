require "../spec_helper"

describe Enumerable do
  describe "#accumulate" do
    it { ([] of Int32).accumulate.should eq([] of Int32) }
    it { [1, 2, 3].accumulate.should eq([1, 3, 6]) }
    it { [1, 2, 3].accumulate(4).should eq([5, 7, 10]) }
    it { [1, 2, 3].accumulate(4.5).should eq([5.5, 7.5, 10.5]) }
    it { (1..3).accumulate { |a, b| a + b }.should eq([1, 3, 6]) }
    it { (1..3).accumulate { |a, b| a - b }.should eq([-1, -3, -6]) }
    it { (1..3).accumulate(1.5) { |a, b| a + b }.should eq([2.5, 4.5, 7.5]) }

    it "uses zero from type" do
      typeof([1, 2, 3].accumulate).should eq(Array(Int32))
      typeof([1.5, 2.5, 3.5].accumulate).should eq(Array(Float64))
    end
  end
end
