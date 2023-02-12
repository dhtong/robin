module Records
  class UserContactAssociation < ApplicationRecord
    belongs_to :customer_user
    belongs_to :contact_user
  end
end
