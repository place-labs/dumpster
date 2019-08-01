require "./stats"

module Math::Correlation
  # Find the Pearson correlation coefficent for `self` and *other*.
  def correlation(other : Enumerable)
    covariance(other) / (stddev * other.stddev)
  end

  # Computes the covariance with another `Enumerable`.
  def covariance(other : Enumerable)
    raise ArgumentError.new("sizes must be uniform") if other.size != size
    e = mean * other.mean
    zip(other).map { |x, y| x * y - e }.mean #.sum / (size - 1)
  end
end

module Enumerable(T)
  include Math::Correlation
end
