module Slack::Actions
  class NewChannelConfig

    def initialize
      @channel_config_presenter_class = ::Presenters::Slack::BaseChannelConfig
    end

    def execute
      case action["selected_option"]["value"]
      when "zenduty"
        @slack_client.views_update(view_id: @payload["view"]["id"], view: zenduty_token_input_view)
      when "pagerduty"
        @slack_client.views_update(view_id: @payload["view"]["id"], view: pagerduty_auth_redirect_view(@customer.external_id))
      end
    end
  end
end