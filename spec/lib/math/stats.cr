require "../../spec_helper"

describe Enumerable do
  describe "#mean" do
    it { [4, 36, 45, 50, 75].mean.should eq(42) }
    it { (1..6).mean.should eq(3.5) }
  end

  describe "#var" do
    it { (1..6).var.should be_close(2.917, 1e-3) }
    it { (1..6).var(ddof: 1).should eq(3.5) }
  end

  describe "#std" do
    it { [2, 4, 4, 4, 5, 5, 7, 9].std.should eq(2) }
    it { (1..6).std.should be_close(1.708, 1e-3) }
    it { (1..6).std(ddof: 1).should be_close(1.871, 1e-3) }
  end
end
