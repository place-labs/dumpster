require "linalg"

module Dumpster::NumTools
  extend self

  # Perform a univariate linear regression for a set of points and return a
  # `Tuple` of the coefficients.
  def linreg(points : Indexable({Number, Number}))
    _X = LA::GMat.new(points.size, 2) do |i, j|
      if j == 0
        1
      else
        points[i][0]
      end
    end

    y = LA::Mat.column(points.map &.[](1))

    alpha, beta, _ = LA.solvels(_X, y).to_a

    {alpha, beta}
  end
end

# TODO: submit back to crystal stbdlib
module Enumerable(T)
  # Returns as `Array` of cumulative values, starting from zero.
  #
  # ```
  # (1..3).accumulate #=> [1, 3, 6]
  # ```
  def accumulate
    accumulate Reflect(T).first.zero
  end

  # Returns as `Array` of cumulative values, starting from *initial*.
  #
  # ```
  # (1..3).accumulate(10) #=> [11, 13, 16]
  # ```
  def accumulate(initial)
    accumulate(initial) { |a, b| a + b }
  end

  # Returns an `Array` of accumulate values of applying *block* to each element
  # in the collection and the previous accumulated value, starting with the
  # zero.
  #
  # ```
  # (1..3).accumulate { |a, b| a - b } #=> [-1, -3, -6]
  # ```
  def accumulate(&block)
    accumulate(Reflect(T).first.zero) { |a, b| yield a, b }
  end

  # Accumulate the results of applying the passed block each element in the
  # collection and the previous cumulative value, starting with *initial*.
  #
  # ```
  # (1..3).accumulate(10) { |a, b| a + b } #=> [11, 13, 16]
  # ```
  def accumulate(initial : U, &block : U, T -> U) forall U
    reduce([] of U) do |accum, e|
      accum << yield(accum.last { initial }, e)
    end
  end
end
