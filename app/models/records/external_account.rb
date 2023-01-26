module Records
  class ExternalAccount < ApplicationRecord
    belongs_to :customer
    has_many :channel_configs
    default_scope { where(disabled_at: nil) }
    scope :slack, -> { where(platform: "slack") }

    def client
      return @client if @client.present?
      case platform
      when "zenduty"
        @client = Zenduty::Client.new(token)
      when "pagerduty"
        @client = Pagerduty::ApiClient.new(token)
      end
      @client
    end
  end
end
