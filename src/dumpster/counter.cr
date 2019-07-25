# Util for tracking a set of counters associated with keys of an arbitary type.
#
# OPTIMIZE: depending on number of entries being tracked, there may be a point
# where it make sense to swap this out for a count-min-sketch, but a Hash is
# simple for now...
class Dumpster::Counter(T)
  def initialize
    @counts = Hash(T, UInt32).new { |h, k| h[k] = 0_u32 }
  end

  def increment(key : T)
    @counts[key] += 1
  end

  def count(key : T)
    @counts[key]
  end

  delegate each, to: @counts
end
