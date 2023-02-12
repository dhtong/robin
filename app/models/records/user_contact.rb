module Records
  class UserContact < ApplicationRecord
    has_many :customer_users, through: :user_contact_associations
  end
end
