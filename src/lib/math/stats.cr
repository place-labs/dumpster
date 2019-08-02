require "math"

# Extensions for the `Enumerable` module to support common stats methods.
module Math::Stats
  # Compute the mean for values contained within the collection.
  #
  # ```
  # (1..6).mean # => 3.5
  # ```
  def mean
    sum / size.to_f
  end

  # Compute the variance across values contained in the collection.
  #
  # Default normalisation (N) is applied such that this may be used directly on
  # collections representing the full population. When working with a sample,
  # *ddof* may be used to specify a delta degrees of freedom and correct bias.
  #
  # ```
  # (1..6).var # => 2.917
  # ```
  def var(ddof = 0.0)
    return 0.0 if size == 0
    u = mean
    sum { |x| (x - u) ** 2 } / (size - ddof)
  end

  # Compute the standard deviation for values within the collection.
  #
  # ```
  # (1..6).std # => 1.708
  # ```
  def std(ddof = 0.0)
    Math.sqrt var(ddof)
  end
end

module Enumerable(T)
  include Math::Stats
end
