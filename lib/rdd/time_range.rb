module Rdd

  # Activity for 1/1/2015 @ 3PM UTC   2015-01-01-15
  # Activity for 1/1/2015             2015-01-01-{0..23}
  # Activity for all of January 2015  2015-01-{01..30}-{0..23}
  # yyyy-mm-dd-{dd..dd}-{hh..hh}

  class TimeRange
    attr_accessor :after, :before
    def initialize(after,before)
      @after = after
      @before = before
    end
    def dd
      after = @after.strftime("%d")
      before = @before.strftime("%d")
      return "{#{ after }..#{ before }}" if @before.day > @after.day
      return after if @after
      return before if @before
    end
    def hh
      after = @after.strftime("%k").strip
      before = @before.strftime("%k").strip
      if @before.day <= @after.day
        if @before.hour > @after.hour
          return "-{#{ after }..#{ before }}"
        end
        return "-#{after}" if @after
        return "-#{before}" if @before
      end
      end
    def composite
      "#{@after.strftime("%Y-%m")}-#{dd}#{hh}"
    end
  end

end