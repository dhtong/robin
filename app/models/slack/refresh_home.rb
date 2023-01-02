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
      blocks << select_integration

      if external_accounts.any?
        blocks.push(*display_existing_integrations(external_accounts))
        # todo show accounts and edit accounts
      end

      @client.views_publish(
        user_id: @caller_id,
        view: {type: 'home', blocks: blocks}
      )
    end

    private

    def display_existing_integrations(external_accounts)
      blocks = [
        {type: 'section', text: {type: 'mrkdwn', text: "*Your tools*"}}, 
        {type: 'divider'}
      ]
      external_accounts.each do |account|
        blocks << view_integration(account.platform)
      end
      blocks
    end

    def view_integration(platform_name)
      {
        "type": "section",
        "block_id": "integration_edit_" + platform_name + "-block",
        "text": {
          "type": "mrkdwn",
          "text": platform_name
        },
        "accessory": {
          "type": "overflow",
          "action_id": "integration_edit_" + platform_name + "-action",
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