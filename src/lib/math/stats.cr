require "math"

# Extensions for the `Enumerable` module to support common numerical stats
# functions for numeric collections.
module Math::Stats
  def mean
    sum.to_f / size.to_f
  end

  def variance
    return 0.0 if size == 0
    x_bar = mean
    map { |x| (x - x_bar) ** 2 }.mean
  end

  def stddev
    Math.sqrt variance
  end
end

module Enumerable(T)
  include Math::Stats
end
