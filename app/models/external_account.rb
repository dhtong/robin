class ExternalAccount < ApplicationRecord
  belongs_to :customer
  has_many :channel_configs

  def client
    return @client if @client.present?
    case platform
    when "zenduty"
      @client = Zenduty::Client.new(token)
    end
    @client
  end
end
