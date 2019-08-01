require "../../spec_helper"

describe Enumerable do
  describe "#covariance" do
    a = [1, 3, 2, 5, 8, 7, 12, 2, 4]
    b = [8, 6, 9, 4, 3, 3, 2, 7, 7]
    c = [2.1, 2.5, 3.6, 4.0]
    d = [8, 10, 12, 14]
    # FIXME: results here seem to expect a &.sum / (size - 1)???
    # ...but correlation output is correct when using mean
    # it { a.covariance(b).should be_close(-8.07, 1e-2) }
    # it { c.covariance(d).should be_close(2.267, 1e-3) }
  end

  describe "#correlation" do
    a = [1, 2, 3, 4, 6, 7, 8, 9]
    b = [2, 4, 6, 8, 10, 12, 13, 15]
    c = [-1, -2, -2, -3, -4, -6, -7, -8]
    d = a.map { |x| -1 * x }
    it { a.correlation(a).should eq(1) }
    it { a.correlation(b).should be_close(0.99535001, 1e-8) }
    it { a.correlation(c).should be_close(-0.9805214, 1e-8) }
    it { b.correlation(c).should be_close(-0.97172394, 1e-8) }
    it { a.correlation(d).should eq(-1) }
  end
end
