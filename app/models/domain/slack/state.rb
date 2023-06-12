module Domain::Slack
  class State
    
    def initialize(h)
      @h = h
    end

    def [](key)
      @h["values"][key]
    end
  end
end