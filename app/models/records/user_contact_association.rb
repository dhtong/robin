module Records
  class UserContactAssociation < ApplicationRecord
    belongs_to :customer_user
    belongs_to :user_contact
  end
end
