module Presenters::Slack
  class BaseChannelConfig
    CALLBACK_ID = "new_channel_config"
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

    class << self
      def from_blocks(blocks)
        new(blocks)
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