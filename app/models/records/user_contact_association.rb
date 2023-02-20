module Records
  class UserContactAssociation < ApplicationRecord
    belongs_to :customer_user
    belongs_to :user_contact

    enum status: %i[active pending].index_with(&:to_s)
  end
end
