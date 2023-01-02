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
        {"type": "divider"},
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/placeholder.png",
              "alt_text": "placeholder"
            }
          ]
        }
      ]
      external_accounts.each do |account|
        blocks << view_integration(account.platform)
      end
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
        {"type": "divider"},
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/placeholder.png",
              "alt_text": "placeholder"
            }
          ]
        }
      ]
      external_accounts.each do |account|
        # blocks << view_channel(account.platform)
      end
      blocks
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

    # def view_channel(id, text)
    #   {
    #     "type": "section",
    #     "block_id": id + "channel-block",
    #     "text": {
    #       "type": "mrkdwn",
    #       "text": text
    #     },
    #     "accessory": {
    #       "type": "overflow",
    #       "action_id": id + "channel-action",
    #       "options": [
    #         {
    #           "text": {
    #             "type": "plain_text",
    #             "text": "Delete",
    #             "emoji": true
    #           },
    #           "value": "delete"
    #         }
    #       ]
    #     }
    #   }
    # end

    # def top_actions
    #   {
    #     "type": "header",
    #     "text": {
    #       "type": "plain_text",
    #       "text": "Here's what you can do with SupportBots:"
    #     }
    #   },
    #   {
    #     "block_id": "main_action-block",
    #     "type": "actions",
    #     "elements": [
    #       {
    #         "action_id": "integrate-action",
    #         "type": "button",
    #         "text": {
    #           "type": "plain_text",
    #           "text": "Integrate",
    #           "emoji": true
    #         },
    #         "style": "primary",
    #         "value": "integrate"
    #       },
    #       # {
    #       #   "type": "button",
    #       #   "text": {
    #       #     "type": "plain_text",
    #       #     "text": "Help",
    #       #     "emoji": true
    #       #   },
    #       #   "value": "help"
    #       # }
    #     ]
    #   },
    #   {
    #     "type": "context",
    #     "elements": [
    #       {
    #         "type": "image",
    #         "image_url": "https://api.slack.com/img/blocks/bkb_template_images/placeholder.png",
    #         "alt_text": "placeholder"
    #       }
    #     ]
    #   }
    # end

    # def select_integration
    #   {
    #     "type": "section",
    #     "block_id": "integration_selection-block",
    #     "text": {
    #       "type": "mrkdwn",
    #       "text": "Pick a tool to integrate with"
    #     },
    #     "accessory": {
    #       "action_id": "integration_selection-action",
    #       "type": "static_select",
    #       "placeholder": {
    #         "type": "plain_text",
    #         "text": "Select a tool",
    #         "emoji": true
    #       },
    #       "options": [
    #         {
    #           "text": {
    #             "type": "plain_text",
    #             "text": "Pagerduty",
    #             "emoji": true
    #           },
    #           "value": "pagerduty"
    #         },
    #         {
    #           "text": {
    #             "type": "plain_text",
    #             "text": "Zenduty",
    #             "emoji": true
    #           },
    #           "value": "zenduty"
    #         },
    #       ],
    #     }
    #   }
    # end
  end
end