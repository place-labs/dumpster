require "../spec_helper"

describe Dumpster::NumTools do
  describe ".linreg" do
    it "correctly calculates coefficients" do
      points = [{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5}]
      intercept, slope = Dumpster::NumTools.linreg points
      intercept.should be_close(1, 1e-5)
      slope.should be_close(1, 1e-5)

      points = [{0, 0}, {1, 1}, {2, 2}, {3, 3}, {4, 4}]
      intercept, slope = Dumpster::NumTools.linreg points
      intercept.should be_close(0, 1e-5)
      slope.should be_close(1, 1e-5)
    end
  end

  describe ".correlate" do
    a = [1, 2, -2, 4, 2, 3, 1, 0]
    b = [2, 3, -2, 3, 2, 4, 1, -1]
    c = [-2, 0, 4, 0, 1, 1, 0, -2]
    d = a.map { |x| -1 * x }

    it "produces a cross-correlation matrix for a list of series" do
      correlations = Dumpster::NumTools.correlate [a, b, c, d]
      puts correlations
      correlations[0, 0].should eq(1)
      correlations[0, 1].should be_close(0.915, 1e-3)
      correlations[0, 2].should be_close(-0.314, 1e-3)
      correlations[0, 3].should eq(-1)
    end
  end
end
