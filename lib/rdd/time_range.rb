module Rdd

  class TimeRange
    attr_accessor :after, :before
    def initialize(after,before)
      @after = after
      @before = before
    end
    def hh
      after = @after.strftime("%H")
      before = @before.strftime("%H")
      return "{#{ after }..#{ before }}" unless @before > @after
      return after if @after
      return before if @before
    end
    def dd
      after = @after.strftime("%d")
      before = @before.strftime("%d")
      return "{#{ after }..#{ before }}" unless @before > @after
      return after if @after
      return before if @before
    end
    def composite
      "#{@after.strftime("%Y-%m")}-#{dd}-#{hh}"
    end
  end

end