module Records
  class Customer < ApplicationRecord
    has_many :external_accounts
    attribute :external_id, :string, default: -> { SecureRandom.uuid }

    def slack_client
      Slack::Web::Client.new(token: slack_access_token)
    end
  end
end
