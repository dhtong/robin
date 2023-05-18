module Slack::Actions
  class NewChannelConfig

    def initialize
      @channel_config_presenter_class
    end

    def execute
      selected_platform = @payload["actions"][0]["selected_option"]["value"]
      selected_account = @customer.external_accounts.where(platform: selected_platform).first

      case selected_platform
      when "zenduty"
        presenter = Presenters::Slack::ZendutyChannelConfig.from_blocks(@payload["view"]["blocks"])
        presenter.with_teams(selected_account.client.get_teams)  
      when "pagerduty"
        presenter = Presenters::Slack::PagerdutyChannelConfig.from_blocks(@payload["view"]["blocks"])
        schedules = selected_account.client.list_schedules
        presenter.with_schedules(schedules)
      end
      
      @slack_client.views_update(view_id: @payload["view"]["id"], view: presenter.present)
    end
  end
end