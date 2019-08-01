require "math"
require "linalg"
require "../lib/math"

module Dumpster::NumTools
  extend self

  # Perform a univariate linear regression for a set of points.
  def linreg(points : Enumerable({Number, Number}))
    a = LA::GMat.new(points.size, 2)
    b = LA::GMat.new(points.size, 1)

    points.each.with_index do |(x, y), i|
      a[i, 0] = 1
      a[i, 1] = x
      b[i, 0] = y
    end

    b0, b1, r, p, e = LA.solvels(a, b).to_a

    {
      intercept: b0,
      slope: b1,
      r_value: r,
      p_value: p,
      stderr: e
    }
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
    m = LA::GMat.identity(series.size)

    # Fill in the blanks for each other pairwise combination
    series.each.with_index do |a, i|
      (i + 1..series.size - 1).each do |j|
        b = series[j]
        correlation = a.dot(b) / Math.sqrt(squares[i] * squares[j])
        m[i, j] = m[j, i] = correlation
      end
    end

    m.assume! LA::MatrixFlags::Symmetric

    m
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

module Enumerable(T)
  # Compute the dot product of `self` and *other*.
  def dot(other : Enumerable)
    raise ArgumentError.new("sizes must be uniform") if size != other.size
    raise ArgumentError.new("size must be > 0") unless size > 0
    zip(other).sum &.product
  end
end
