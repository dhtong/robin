module Slack::Actions
  class SelectEscalationPolicySource

    def initialize
      @zenduty_presenter = Presenters::Slack::ZendutyChannelConfig
      @pagerduty_presenter = Presenters::Slack::PagerdutyChannelConfig
    end

    def execute(customer, interaction)
      selected_platform = interaction.actions[0].selected_option.value
      selected_account = customer.external_accounts.where(platform: selected_platform).first
      case selected_platform
      when "zenduty"
        presenter = @zenduty_presenter.from_dry_blocks(interaction.view.blocks)
        presenter.with_teams(selected_account.client.get_teams)  
      when "pagerduty"
        presenter = @pagerduty_presenter.from_dry_blocks(interaction.view.blocks)
        schedules = selected_account.client.list_schedules
        presenter.with_schedules(schedules)
      end
      
      Slack::Web::Client.new(token: customer.slack_access_token).
        views_update(view_id: interaction.view.id, view: presenter.present)
    end
  end
end