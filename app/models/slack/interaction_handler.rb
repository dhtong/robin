module Slack
  class InteractionHandler
    def initialize(customer, client, payload)
      @customer = customer
      @client = client
      @payload = payload

      @trigger_id = payload["trigger_id"]
      @caller_id = payload["user"]["id"]
      @refresh_home_cmd = Slack::RefreshHome.new(customer, client, @caller_id)
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
      end
    end

    def handle_block_actions
      raise StandardError.new("more than one actions") if @payload["actions"].size > 1
      action = @payload["actions"].last
      case action["action_id"]
      when "new_channel_config-action"
        # TODO
      when "add_integration-action"
        @client.views_open(trigger_id: @trigger_id, view: new_integration_selection)
      when "integration_selection-action"
        handle_integration_selection(action)
      end
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
        @client.views_update(view_id: @payload["view"]["id"], view: zenduty_token_input_view)
      when "pagerduty"
        # TODO add pd oath
      end
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

      # {
      #   "title": {
      #     "type": "plain_text",
      #     "text": "Zenduty integration"
      #   },
      #   "blocks": [
      #     {
      #       "block_id": "zenduty_token-block",
      #       "type": "input",
      #       "element": {
      #         "type": "plain_text_input",
      #         "action_id": "zenduty_token-action"
      #       },
      #       "label": {
      #         "type": "plain_text",
      #         "text": "Access token",
      #         "emoji": true
      #       }
      #     }
      #   ],
      #   "type": "modal",
      #   "callback_id": "modal_zenduty_token"
      # }
    end

    # TODO make options dynamic.
    # remove the option once an integration is already set up.
    def new_integration_selection
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
              "options": [
                {
                  "text": {
                    "type": "plain_text",
                    "text": "Zenduty",
                    "emoji": true
                  },
                  "value": "zenduty"
                }
              ],
              "action_id": "integration_selection-action"
            }
          }
        ]
      }
    end
  end
end
