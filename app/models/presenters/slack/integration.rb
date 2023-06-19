module Presenters::Slack
  class Integration
    CALLBACK_ID = "new_integration"
    PAGERDUTY_AUTH_BLOCK_ID = "pagerduty_auth-block"
    BASE_VIEW = {
      "type": "modal",
      "callback_id": CALLBACK_ID,
      "title": {
        "type": "plain_text",
        "text": "Integrations",
      },
      "close": {
        "type": "plain_text",
        "text": "Close",
      }
    }

    class << self
      def from_blocks(blocks)
        new(blocks)
      end

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

    def initialize(blocks)
      @blocks = blocks || []
      @submit = {"type": "plain_text", "text": "Close", "emoji": true}
    end

    def set_pagerduty_redirect(url)
      @blocks[1] = token_block = {
        "block_id": PAGERDUTY_AUTH_BLOCK_ID,
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "This button will redirect you to pagerduty to give this app access"
        },
        "accessory": {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "Redirect",
            "emoji": true
          },
          "value": "pd_redirect",
          "url": url,
          "action_id": "button-action"
        }
      }
      @submit = {"type": "plain_text", "text": "Done", "emoji": true}
    end

    def present
      view = BASE_VIEW
      view[:blocks] = @blocks
      view[:submit] = @submit
      view
    end
  end
end