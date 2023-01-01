module Slack
  class RefreshHome
    def initialize(customer, client, caller_id)
      @customer = customer
      @client = client
      @caller_id = caller_id
    end


    def execute
      external_accounts = @customer.external_accounts

      blocks = []
      if external_accounts.any?
        blocks << {type: 'section', text: {type: 'mrkdwn', text: "Here are the accounts"} }
        # todo show accounts
      end

      blocks << select_integration

      @client.views_publish(
        user_id: @caller_id,
        view: {type: 'home', blocks: blocks}
      )
    end

    private

    def select_integration
      {
        "type": "section",
        "block_id": "block_integration_selection",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a tool to integrate with"
        },
        "accessory": {
          "action_id": "action_integration_selection",
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Select a tool",
            "emoji": true
          },
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "Pagerduty",
                "emoji": true
              },
              "value": "pagerduty"
            },
            {
              "text": {
                "type": "plain_text",
                "text": "Zenduty",
                "emoji": true
              },
              "value": "zenduty"
            },
          ],
        }
      }
    end
  end
end