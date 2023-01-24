class Customer < ApplicationRecord
  has_many :external_accounts
  attribute :external_id, :string, default: -> { SecureRandom.uuid }
end
