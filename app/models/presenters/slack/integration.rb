module Presenters::Slack
  class Integration
    CALLBACK_ID = "new_integration"
    PAGERDUTY_AUTH_BLOCK_ID = "pagerduty_auth-block"

    class << self
      def no_integrations_available
        {
          "type": "modal",
          "callback_id": CALLBACK_ID,
          "title": {
            "type": "plain_text",
            "text": "Integrations",
          },
          "close": {
            "type": "plain_text",
            "text": "Close",
          },
          "blocks": [
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "No more integrations available.\nPlease edit existing ones or file a new integration feature request!"
              }
            }
          ]
        }
      end

      def new_integration_selection(available_options)
        {
          "type": "modal",
          "callback_id": CALLBACK_ID,
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
                "options": option_blocks(available_options),
                "action_id": "integration_selection-action"
              }
            }
          ]
        }
      end

      private

      def option_blocks(options)
        options.map do |o|
          {
            "text": {
              "type": "plain_text",
              "text": o.camelize,
              "emoji": true
            },
            "value": o.downcase
          }
        end
      end
    end
  end
end