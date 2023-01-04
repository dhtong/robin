module Presenters
  class SlackZendutyChannelConfig
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
        "action_id": "conversations_select-action"
      },
      "label": {
        "type": "plain_text",
        "text": "Channel",
      }
    }
    PLATFORM_BLOCK_ID = "schedule_source_selection-block"
    PLATFORM_ACTION_ID = "schedule_source_selection-action"
    TEAM_BLOCK_ID = "schedule_source_selection_team-block"
    SCHEDULE_BLOCK_ID = "schedule_source_selection_team_schedule-block"
    SCHEDULE_ACTION_ID = "schedule_source_selection_team_schedule-action"

    class << self
      def from_blocks(blocks)
        new(blocks)
      end

      def from_external_accounts(external_accounts)
        blocks = [CONVERSATION_BLOCK, source_block(external_accounts)]
        new(blocks)
      end

      private

      def source_block(external_accounts)
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
            "options": source_options(external_accounts),
            "action_id": "schedule_source_selection-action"
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

    def with_teams(teams)
      @blocks[2] = team_block(teams)
    end

    def with_schedules(schedules)
      if @blocks.length < 3
        return raise StandardError
      end
      @blocks[3] = schedule_block(schedules)
    end

    private

    def schedule_block(schedules)
      {
        "type": "input",
        "block_id": "schedule_source_selection_team_schedule-block",
        "label": {
          "type": "plain_text",
          "text": "Pick a schedule"
        },
        "element": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "schedule"
          },
          "options": schedule_options(schedules),
          "action_id": "schedule_source_selection_team_schedule-action"
        }
      }
    end

    def team_block(teams)
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a team"
        },
        "block_id": TEAM_BLOCK_ID,
        "accessory": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "team"
          },
          "options": team_options(teams),
          "action_id": "schedule_source_selection_team-action"
        }
      }
    end

    def team_options(teams)
      teams.map do |team|
        {
          "text": {
            "type": "plain_text",
            "text": team["name"],
          },
          "value": team["unique_id"]
        }
      end
    end

    def schedule_options(schedules)
      schedules.map do |schedule|
        {
          "text": {
            "type": "plain_text",
            "text": schedule["name"],
          },
          "value": schedule["unique_id"]
        }
      end
    end
  end
end