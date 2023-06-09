module Slack::Actions
  class SelectIntegration
    ZENDUTY_TOKEN_BLOCK_ID = "zenduty_token-block"

    def execute(customer, interaction)
      @customer = customer
      slack_client = Slack::Web::Client.new(token: customer.slack_access_token)
      action = interaction.actions[-1]
      case action.selected_option.value
      when "zenduty"
        slack_client.views_update(view_id: interaction.view.id, view: zenduty_token_input_view)
      when "pagerduty"
        slack_client.views_update(view_id: interaction.view.id, view: pagerduty_auth_redirect_view(customer.external_id))
      end
    end

    private

    INTEGRATION_OPTIONS = %w[zenduty pagerduty]

    # todo move this to presenters
    def zenduty_token_input_view
      view = new_integration_selection
      view[:submit] = {"type": "plain_text", "text": "Submit", "emoji": true}
      token_block = {
        "block_id": ZENDUTY_TOKEN_BLOCK_ID,
        "type": "input",
        "element": {
          "type": "plain_text_input",
          "action_id": "zenduty_token-action"
        },
        "label": {
          "type": "plain_text",
          "text": "Access token",
          "emoji": true
        }
      }
      view[:blocks] << token_block
      view
    end

     # todo move this to presenters
    def pagerduty_auth_redirect_view(external_id)
      view = new_integration_selection
      view[:submit] = {"type": "plain_text", "text": "Done", "emoji": true}
      url = "https://identity.pagerduty.com/oauth/authorize?client_id=8bded887-2b85-4e2a-85a3-7ef758afb8ae&redirect_uri=#{Pagerduty::OauthClient.get_redirect_uri(external_id)}&scope=read&response_type=code"
      token_block = {
        "block_id": Presenters::Slack::Integration::PAGERDUTY_AUTH_BLOCK_ID,
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "This button will redirect you to pagerduty to give this app access"
        },
        "accessory": {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "Redirect",
            "emoji": true
          },
          "value": "pd_redirect",
          "url": url,
          "action_id": "button-action"
        }
      }
      view[:blocks] << token_block
      view
    end

    def new_integration_selection
      existing_options = @customer.external_accounts.pluck(:platform)
      available_options = INTEGRATION_OPTIONS - existing_options
      if available_options.empty?
        return Presenters::Slack::Integration.no_integrations_available
      end
      Presenters::Slack::Integration.new_integration_selection(available_options)
    end
  end
end