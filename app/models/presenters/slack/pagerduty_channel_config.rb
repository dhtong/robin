module Presenters::Slack
  class PagerdutyChannelConfig < BaseChannelConfig
    def with_schedules(schedules)
      @blocks[2] = schedule_block(schedules)
      @blocks = @blocks[..2]
    end

    private

    def schedule_block(schedules)
      {
        "type": "input",
        "label": {
          "type": "plain_text",
          "text": "Pick a schedule"
        },
        "block_id": ESCALATION_POLICY_BLOCK_ID,
        "element": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "schedule"
          },
          "options": schedule_options(schedules),
          "action_id": ESCALATION_POLICY_ACTION_ID
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