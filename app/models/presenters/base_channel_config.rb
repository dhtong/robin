module Presenters
  class BaseChannelConfig
    CALLBACK_ID = "new_channel_config"

    def initialize(external_accounts)
      @external_accounts = external_accounts
    end

    def present
      {
        "type": "modal",
        "callback_id": CALLBACK_ID,
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
              },
              "action_id": "conversations_select-action"
            },
            "label": {
              "type": "plain_text",
              "text": "Channel",
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Pick a service to get schedule from"
            },
            "block_id": "schedule_source_selection-block",
            "accessory": {
              "type": "static_select",
              "placeholder": {
                "type": "plain_text",
                "text": "Service",
              },
              "options": source_options,
              "action_id": "schedule_source_selection-action"
            }
          }
        ]
      }
    end

    private

    def source_options
      @external_accounts.map do |account|
        {
          "text": {
            "type": "plain_text",
            "text": account.platform.capitalize,
          },
          "value": account.platform
        }
      end
    end
  end
end