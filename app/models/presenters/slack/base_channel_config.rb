module Presenters::Slack
  class BaseChannelConfig
    CALLBACK_ID = "new_channel_config"
    PLATFORM_BLOCK_ID = "escalation_policy_source_selection-block"
    PLATFORM_ACTION_ID = "escalation_policy_source_selection-action"
    ESCALATION_POLICY_BLOCK_ID = "escalation_policy-block"
    ESCALATION_POLICY_ACTION_ID = "escalation_policy-action"

    BASE_VIEW = {
      "type": "modal",
      "callback_id": CALLBACK_ID,
      "title": {
        "type": "plain_text",
        "text": "Channel config",
      },
      "submit": {
        "type": "plain_text",
        "text": "Submit",
      }
    }
    CONVERSATION_BLOCK = {
      "block_id": "conversations_select-block",
      "type": "input",
      "element": {
        "type": "conversations_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select channel",
        },
        "filter": {
          "include": [
            "public",
            "private"
          ],
          "exclude_bot_users": true
        },
        "action_id": "conversations_select-action"
      },
      "label": {
        "type": "plain_text",
        "text": "Channel",
      }
    }

    SUBSCRIBER_BLOCK = {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "[optional] Subscribers to always get a private ping"
			},
			"accessory": {
				"type": "multi_users_select",
				"placeholder": {
					"type": "plain_text",
					"text": "Select",
				},
				"action_id": "multi_subscribers_select-action"
			}
		}

    class << self
      def from_blocks(blocks)
        new(blocks)
      end

      def from_external_accounts(external_accounts)
        blocks = [CONVERSATION_BLOCK, SUBSCRIBER_BLOCK, source_block(external_accounts)]
        new(blocks)
      end

      private

      def source_block(external_accounts)
        {
          "dispatch_action": true,
          "type": "input",
          "label": {
            "type": "plain_text",
            "text": "Pick a service to get a schedule or escalation policy from"
          },
          "block_id": PLATFORM_BLOCK_ID,
          "element": {
            "type": "static_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Service",
            },
            "options": source_options(external_accounts),
            "action_id": PLATFORM_ACTION_ID
          }
        }
      end

      def source_options(external_accounts)
        external_accounts.map do |account|
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

    def initialize(blocks)
      @blocks = blocks
    end

    def present
      view = BASE_VIEW
      view[:blocks] = @blocks
      view
    end
  end
end