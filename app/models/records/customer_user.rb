module Records
  class CustomerUser < ApplicationRecord
    has_many :user_contact_associations
    has_many :user_contacts, through: :user_contact_associations

    has_many :channel_subscribers
    has_many :channel_configs, through: :channel_subscribers
    belongs_to :customer
  end
end
