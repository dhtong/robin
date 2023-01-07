module Slack
  class RefreshHome
    def initialize(customer, client, caller_id)
      @customer = customer
      @client = client
      @caller_id = caller_id
    end


    def execute
      external_accounts = @customer.external_accounts

      blocks = display_integrations(external_accounts)

      if external_accounts.any?
        blocks.push(*display_channel_configs(external_accounts))
      end

      @client.views_publish(
        user_id: @caller_id,
        view: {type: 'home', blocks: blocks}
      )
    end

    private

    EMPTY_SPACE = {
      "type": "context",
      "elements": [
        {
          "type": "image",
          "image_url": "https://api.slack.com/img/blocks/bkb_template_images/placeholder.png",
          "alt_text": "placeholder"
        }
      ]
    }

    def display_integrations(external_accounts)
      blocks = [
        {
          "type": "section",
          "text": {"type": "mrkdwn", "text": "*Integrations*"},
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "Add",
              "emoji": true
            },
            "action_id": "add_integration-action",
            "value": "add_integration"
          }
        }, 
        {"type": "divider"}
      ]
      external_accounts.each do |account|
        blocks << view_integration(account.platform)
      end

      blocks << EMPTY_SPACE
      blocks
    end

    def display_channel_configs(external_accounts)
      blocks = [
        {
          "type": "section",
          "text": {"type": "mrkdwn", "text": "*Oncall channels*"},
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "New",
              "emoji": true
            },
            "action_id": "new_channel_config-action",
            "value": "new_channel_config"
          }
        }, 
        {"type": "divider"}
      ]
      external_accounts.each do |account|
        account.channel_configs.each do |channel_config|
          blocks << view_channel(channel_config)
        end
      end
      blocks
    end

    def view_channel(channel_config)
      {
        "type": "section",
        "block_id": channel_config.id.to_s + "_edit_channel_config-block",
        "text": {
          "type": "mrkdwn",
          "text": "<##{channel_config.channel_id}>"
        },
        "accessory": {
          "type": "overflow",
          "action_id": channel_config.id.to_s + "_edit_channel_config-action",
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "Delete",
                "emoji": true
              },
              "value": "delete"
            }
          ]
        }
      }
    end


    def view_integration(integration_name)
      {
        "type": "section",
        "block_id": integration_name + "_integration-block",
        "text": {
          "type": "mrkdwn",
          "text": integration_name
        },
        "accessory": {
          "type": "overflow",
          "action_id": integration_name + "_integration-action",
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "Delete",
                "emoji": true
              },
              "value": "delete"
            }
          ]
        }
      }
    end
  end
end