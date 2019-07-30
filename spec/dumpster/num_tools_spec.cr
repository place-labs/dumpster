require "../spec_helper"

describe Dumpster::NumTools do
  describe ".linreg" do
    it "correctly calculates coefficients" do
      points = [{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5}]
      alpha, beta = Dumpster::NumTools.linreg points
      alpha.should be_close(1, 1e-5)
      beta.should be_close(1, 1e-5)

      points = [{0, 0}, {1, 1}, {2, 2}, {3, 3}, {4, 4}]
      alpha, beta = Dumpster::NumTools.linreg points
      alpha.should be_close(0, 1e-5)
      beta.should be_close(1, 1e-5)
    end
  end

  describe ".correlate" do
    it "calculates normalised cross-correlation" do
      a = [1, 2, -2, 4, 2, 3, 1, 0]
      b = [2, 3, -2, 3, 2, 4, 1, -1]
      c = [-2, 0, 4, 0, 1, 1, 0, -2]
      a_inv = a.map { |x| -1 * x }

      Dumpster::NumTools.correlate(a, a).should eq(1)
      Dumpster::NumTools.correlate(a, a_inv).should eq(-1)
      Dumpster::NumTools.correlate(a, b).should be_close(0.947, 1e-3)
      Dumpster::NumTools.correlate(a, c).should be_close(-0.157, 1e-3)
    end
  end
end

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
