module Slack
  class InteractionHandler
    def initialize(customer, slack_client, payload)
      @customer = customer
      @slack_client = slack_client
      @payload = payload

      @trigger_id = payload["trigger_id"]
      @caller_id = payload["user"]["id"]
      @refresh_home_cmd = Slack::RefreshHome.new(customer, slack_client, @caller_id)
    end
  
    def execute
      case @payload["type"]
      when "block_actions"
        handle_block_actions
      when "view_submission"
        handle_view_submission
      end
    end
  
    private

    # process modal view submission. this usually results in a (db) state change.
    def handle_view_submission
      case @payload["view"]["callback_id"]
      when "new_integration"
        handle_zenduty_token_submission
      when "new_channel_config"
        handle_new_channel_config_submission
      end
    end

    def handle_block_actions
      raise StandardError.new("more than one actions") if @payload["actions"].size > 1
      action = @payload["actions"].last
      case action["action_id"]
      when "new_channel_config-action"
        presenter = Presenters::BaseChannelConfig.new(@customer.external_accounts)
        @slack_client.views_open(trigger_id: @trigger_id, view: presenter.present)
      when "add_integration-action"
        @slack_client.views_open(trigger_id: @trigger_id, view: new_integration_selection)
      when "integration_selection-action"
        handle_integration_selection(action)
      when "schedule_source_selection-action"
        handle_schedule_source_selection
      end
    end

    def handle_schedule_source_selection
      external_accounts = @customer.external_accounts
      selected_account = external_accounts.find { |a| a.platform == @payload["actions"][0]["selected_option"]["value"] }
      presenter = Presenters::SlackZendutyChannelConfig.new(external_accounts, selected_account.client.get_teams)
      @slack_client.views_update(view_id: @payload["view"]["id"], view: presenter.present_team)
    end

    def handle_integration_edit(state_value)
      state_value.each do |action_id, action_value|
        case action_id
        when "integration_edit_zenduty-action"
          p action_value
        end
      end
    end
  
    def handle_zenduty_token_submission
      zenduty_token = @payload["view"]["state"]["values"]["zenduty_token-block"]["zenduty_token-action"]["value"]
      ExternalAccount.create(customer: @customer, platform: "zenduty", token: zenduty_token)
    end
  
    def handle_integration_selection(action)
      case action["selected_option"]["value"]
      when "zenduty"
        @slack_client.views_update(view_id: @payload["view"]["id"], view: zenduty_token_input_view)
      when "pagerduty"
        # TODO add pd oath
      end
    end

    def handle_new_channel_config_submission
      # @slack_client.views_update(view_id: @payload["view"]["id"], view: zenduty_token_input_view)
      ValidationError.new("conversations_select-block", "Invalid token")
    end

    def new_channel_config
      {
        "type": "modal",
        "callback_id": "new_channel_config",
        "title": {
          "type": "plain_text",
          "text": "Channel config",
        },
        "submit": {
          "type": "plain_text",
          "text": "Submit",
        },
        "blocks": [
          {
            "block_id": "conversations_select-block",
            "type": "input",
            "element": {
              "type": "conversations_select",
              "placeholder": {
                "type": "plain_text",
                "text": "Select channel",
                "emoji": true
              },
              "action_id": "conversations_select-action"
            },
            "label": {
              "type": "plain_text",
              "text": "Channel",
              "emoji": true
            }
          }
        ]
      }
    end
  
    def zenduty_token_input_view
      view = new_integration_selection
      view[:submit] = {"type": "plain_text", "text": "Submit", "emoji": true}
      token_block = {
        "block_id": "zenduty_token-block",
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

    INTEGRATION_OPTIONS = [
      {
        "text": {
          "type": "plain_text",
          "text": "Zenduty",
          "emoji": true
        },
        "value": "zenduty"
      }
    ]

    def new_integration_selection
      existing_options = @customer.external_accounts.pluck(:platform).to_set
      available_options = INTEGRATION_OPTIONS.select { |o| existing_options.exclude?(o[:value]) }
      if available_options.empty?
        return {
          "type": "modal",
          "callback_id": "new_integration",
          "title": {
            "type": "plain_text",
            "text": "Integrations",
          },
          "close": {
            "type": "plain_text",
            "text": "Close",
          },
          "blocks": [
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "No more integrations available.\nPlease edit existing ones or file a new integration feature request!"
              }
            }
          ]
        }
      end

      {
        "type": "modal",
        "callback_id": "new_integration",
        "title": {
          "type": "plain_text",
          "text": "Integrations",
          "emoji": true
        },
        "close": {
          "type": "plain_text",
          "text": "Cancel",
          "emoji": true
        },
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Pick a service to integrate with"
            },
            "block_id": "integration_selection-block",
            "accessory": {
              "type": "static_select",
              "placeholder": {
                "type": "plain_text",
                "text": "Service",
                "emoji": true
              },
              "options": available_options,
              "action_id": "integration_selection-action"
            }
          }
        ]
      }
    end
  end
end
