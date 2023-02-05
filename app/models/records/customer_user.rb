module Records
  class CustomerUser < ApplicationRecord
    belongs_to :customer
  end
end
