require "math"
require "linalg"
require "numcry"

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

    b0, b1, _ = LA.solvels(a, b).to_a

    {b0, b1}
  end

  # Given a list of series, provide a correlation matrix for each pair within.
  def correlate(series : Indexable(Enumerable(Number)))
    if series.any? { |a| a.size != series.first.size }
      raise ArgumentError.new("series must be of the same size")
    end

    # Correlation of each series with itself will always be 1
    m = LA::GMat.identity(series.size)

    # Fill in the blanks for each other pairwise combination
    series.each.with_index do |a, i|
      (i + 1..series.size - 1).each do |j|
        b = series[j]
        m[i, j] = m[j, i] = a.corrcoef b
      end
    end

    m.assume! LA::MatrixFlags::Symmetric

    m
  end
end
