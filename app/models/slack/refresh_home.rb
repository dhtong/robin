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
        # todo show accounts and edit accounts
        blocks << {type: 'section', text: {type: 'mrkdwn', text: "Config schedules"} }
      end

      blocks << select_integration

      @client.views_publish(
        user_id: @caller_id,
        view: {type: 'home', blocks: blocks}
      )
    end

    private

    def display_existing_integrations(external_accounts)
      external_accounts.map do |account|
        view_integration(account.platform)
      end
    end

    def view_integration(platform_name)
      {
        "type": "section",
        "block_id": "block_integration_edit_" + platform_name,
        "text": {
          "type": "mrkdwn",
          "text": "This is a section block with an overflow menu."
        },
        "accessory": {
          "type": "overflow",
          "action_id": "action_integration_edit_" + platform_name,
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "Link schedule to channel",
                "emoji": true
              },
              "value": "link_schedule"
            }
          ]
        }
      }
    end

    def select_integration
      {
        "type": "section",
        "block_id": "integration_selection-block",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a tool to integrate with"
        },
        "accessory": {
          "action_id": "integration_selection-action",
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