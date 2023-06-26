module Records
  class SupportCase < ApplicationRecord
    belongs_to :customer
  end
end
