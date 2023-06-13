module Domain::Slack
  class State
    delegate :dig, to: :@h
    
    def initialize(h)
      @h = h
    end

    def [](key)
      @h["values"][key]
    end
  end
end