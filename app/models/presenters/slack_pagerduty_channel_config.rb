module Presenters
  class SlackPagerdutyChannelConfig < SlackBaseChannelConfig
    SCHEDULE_BLOCK_ID = "pd_schedule_selection-block"
    SCHEDULE_ACTION_ID = "pd_schedule_selection-action"

    def with_schedules(schedules)
      @blocks[2] = schedule_block(schedules)
    end

    private

    def schedule_block(schedules)
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a schedule"
        },
        "block_id": SCHEDULE_BLOCK_ID,
        "accessory": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "schedule"
          },
          "options": schedule_options(schedules),
          "action_id": SCHEDULE_ACTION_ID
        }
      }
    end

    def schedule_options(schedules)
      schedules.map do |schedule|
        {
          "text": {
            "type": "plain_text",
            "text": schedule["summary"],
          },
          "value": schedule["id"]
        }
      end
    end
  end
end