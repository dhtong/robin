module Slack
  class InteractionHandler
    def initialize(customer, client, trigger_id, caller_id)
      @customer = customer
      @client = client
      @trigger_id = trigger_id
      @refresh_home_cmd = Slack::RefreshHome.new(customer, client, caller_id)
    end
  
    def execute(interaction_state, interaction_type: nil)
      interaction_state["values"].each do |block_id, value|
        case block_id
        when "block_zenduty_token"
          handle_zenduty_token_submission(value)
          @refresh_home_cmd.execute
        when "block_integration_selection"
          handle_integration_selection(value)
        when /^block_integration_edit_/
          handle_integration_edit(value)
        end
      end
    end
  
    private

    def handle_integration_edit(state_value)
      state_value.each do |action_id, action_value|
        case action_id
        when "action_integration_edit_zenduty"
          p action_value
        end
      end
    end
  
    def handle_zenduty_token_submission(state_value)
      zenduty_token = state_value["action_zenduty_token"]["value"]
      ExternalAccount.create(customer: @customer, platform: "zenduty", token: zenduty_token)
    end
  
    def handle_integration_selection(state_value)
      begin
        vendor_selected = state_value["action_integration_selection"]["selected_option"]["value"]
        case vendor_selected
        when "zenduty"
          @client.views_open(trigger_id: @trigger_id, view: zenduty_token_input_view)
        when "pagerduty"
          # TODO add pd oath
        end
      rescue => e
        puts "An error of type #{e.class} happened, message is #{e.message}, trace: #{e.backtrace}"
        raise e
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
