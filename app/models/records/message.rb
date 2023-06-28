module Records
  class Message < ApplicationRecord
    belongs_to :customer
    belongs_to :customer_user, optional: true
  end
end
