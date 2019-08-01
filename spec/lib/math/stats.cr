require "../../spec_helper"

describe Enumerable do
  describe "#mean" do
    it { [4, 36, 45, 50, 75].mean.should be_close(42, 1e-10) }
  end

  describe "#variance" do
    it { (1..6).variance.should be_close(2.92, 1e-2) }
  end

  describe "#stddev" do
    it { [2, 4, 4, 4, 5, 5, 7, 9].stddev.should eq(2) }
  end
end
