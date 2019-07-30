# Util for tracking a set of counters associated with keys of an arbitary type.
#
# OPTIMIZE: depending on number of entries being tracked, there may be a point
# where it make sense to swap this out for a count-min-sketch, but a Hash is
# simple for now...
class Dumpster::Counter(T)
  alias Count = UInt32

  def initialize
    @hash = {} of T => Count
  end

  def increment(key : T) : Count
    @hash[key] = count(key) + 1
  end

  def count(key : T) : Count
    @hash[key]? || Count.zero
  end

  delegate each, to: @hash
end
