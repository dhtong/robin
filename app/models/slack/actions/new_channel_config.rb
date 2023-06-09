module Slack::Actions
  class NewChannelConfig

    def initialize
      @channel_config_presenter_class = ::Presenters::Slack::BaseChannelConfig
    end

    def execute(customer, interaction)
      presenter = @channel_config_presenter_class.from_external_accounts(customer.external_accounts)
      Slack::Web::Client.new(token: customer.slack_access_token).
        views_open(trigger_id: interaction.trigger_id, view: presenter.present)
    end
  end
end