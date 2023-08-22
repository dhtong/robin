module Records
  class Event < ApplicationRecord
    belongs_to :message
  end
end
