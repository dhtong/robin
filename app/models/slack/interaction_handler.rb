module Slack
  class InteractionHandler
    def initialize(customer, client, trigger_id)
      @customer = customer
      @client = client
      @trigger_id = trigger_id
    end
  
    def execute(interaction_state, interaction_type: nil)
      interaction_state["values"].each do |block_id, value|
        case block_id
        when "block_zenduty_token"
          handle_zenduty_token_submission(value)
        when "block_integration_selection"
          handle_integration_selection(value)
        end
      end
    end
  
    private
  
    def handle_zenduty_token_submission(state_value)
      binding.b
      zenduty_token = state_value["action_zenduty_token"]["value"]
      ExternalAccount.create(customer: @customer, platform: "zenduty", token: zenduty_token)
    end
  
    def handle_integration_selection(state_value)
      vendor_selected = state_value["action_integration_selection"]["selected_option"]["value"]
      case vendor_selected
      when "zenduty"
        @client.views_open(trigger_id: @trigger_id, view: zenduty_token_input_view)
      end
    end
  
    def zenduty_token_input_view
      {
        "title": {
          "type": "plain_text",
          "text": "Zenduty"
        },
        "submit": {
          "type": "plain_text",
          "text": "Submit"
        },
        "blocks": [
          {
            "block_id": "block_zenduty_token",
            "type": "input",
            "element": {
              "type": "plain_text_input",
              "action_id": "action_zenduty_token",
              "placeholder": {
                "type": "plain_text",
                "text": ""
              }
            },
            "label": {
              "type": "plain_text",
              "text": "Title"
            }
          }
        ],
        "type": "modal"
      }
    end
  end
end
