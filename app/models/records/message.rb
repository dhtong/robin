module Records
  class Message < ApplicationRecord
    belongs_to :customer
  end
end
