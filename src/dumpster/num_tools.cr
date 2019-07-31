require "math"
require "linalg"

module Dumpster::NumTools
  extend self

  # Perform a univariate linear regression for a set of points and return a
  # `Tuple` of the coefficients.
  def linreg(points : Enumerable({Number, Number}))
    a = LA::GMat.new(points.size, 2)
    b = LA::GMat.new(points.size, 1)

    points.each.with_index do |(x, y), i|
      a[i, 0] = 1
      a[i, 1] = x
      b[i, 0] = y
    end

    b0, b1, _ = LA.solvels(a, b).to_a

    {b0, b1}
  end

  # Given two series, provide their normalised cross-correlation.
  def correlate(a : Enumerable(Number), b : Enumerable(Number))
    check_uniform_size! a, b
    a.dot(b) / Math.sqrt(a.dot(a) * b.dot(b))
  end

  # Given a list of series, provide a correlation matrix for each pair within.
  def correlate(series : Indexable(Enumerable(Number)))
    check_uniform_size! series

    # Pre-compute the sum of squares for each series as it's reused in the
    # correlation function.
    squares = series.map { |x| x.dot x }

    # Correlation of each series with itself will always be 1
    correlations = LA::GMat.identity(series.size)

    # Fill in the blanks for each other pairwise combination
    series.each.with_index do |a, i|
      (i + 1..series.size - 1).each do |j|
        b = series[j]
        correlation = a.dot(b) / Math.sqrt(squares[i] * squares[j])
        correlations[i, j] = correlations[j, i] = correlation
      end
    end

    correlations.assume! LA::MatrixFlags::Symmetric

    correlations
  end

  private def check_uniform_size!(*x : Enumerable)
    check_uniform_size! x
  end

  private def check_uniform_size!(x : Enumerable(Enumerable))
    if x.any? { |a| a.size != x.first.size }
      raise ArgumentError.new("series must be of the same size")
    end
  end
end

# TODO: submit back to crystal stbdlib
module Enumerable(T)
  # Returns as `Array` of cumulative values, starting from zero.
  #
  # ```
  # (1..3).accumulate # => [1, 3, 6]
  # ```
  def accumulate
    accumulate Reflect(T).first.zero
  end

  # Returns as `Array` of cumulative values, starting from *initial*.
  #
  # ```
  # (1..3).accumulate(10) # => [11, 13, 16]
  # ```
  def accumulate(initial)
    accumulate(initial) { |a, b| a + b }
  end

  # Returns an `Array` of accumulate values of applying *block* to each element
  # in the collection and the previous accumulated value, starting with the
  # zero.
  #
  # ```
  # (1..3).accumulate { |a, b| a - b } # => [-1, -3, -6]
  # ```
  def accumulate(&block)
    accumulate(Reflect(T).first.zero) { |a, b| yield a, b }
  end

  # Accumulate the results of applying the passed block each element in the
  # collection and the previous cumulative value, starting with *initial*.
  #
  # ```
  # (1..3).accumulate(10) { |a, b| a + b } # => [11, 13, 16]
  # ```
  def accumulate(initial : U, &block : U, T -> U) forall U
    reduce([] of U) do |accum, e|
      accum << yield(accum.last { initial }, e)
    end
  end

  # Compute the dot product of `self` and *other*.
  def dot(other : Enumerable)
    raise ArgumentError.new("sizes must be uniform") if size != other.size
    raise ArgumentError.new("size must be > 0") unless size > 0
    zip(other).sum &.product
  end
end
