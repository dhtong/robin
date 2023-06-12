module Presenters::Slack
  class ZendutyChannelConfig < BaseChannelConfig
    TEAM_BLOCK_ID = "escalation_policy_source_selection_team-block"
    TEAM_ACTION_ID = "escalation_policy_source_selection_team-action"

    def with_teams(teams)
      @blocks[3] = team_block(teams)
      @blocks = @blocks[..3]
    end

    def with_escalation_policies(escalation_policies)
      if @blocks.length < 4
        return raise StandardError
      end
      @blocks[4] = escalation_policy_block(escalation_policies)
    end

    private

    def escalation_policy_block(escalation_policies)
      {
        "type": "input",
        "block_id": ESCALATION_POLICY_BLOCK_ID,
        "label": {
          "type": "plain_text",
          "text": "Pick an escalation policy"
        },
        "element": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "escalation_policy"
          },
          "options": escalation_policy_options(escalation_policies),
          "action_id": ESCALATION_POLICY_ACTION_ID
        }
      }
    end

    def team_block(teams)
      {
        "type": "input",
        "dispatch_action": true,
        "label": {
          "type": "plain_text",
          "text": "Pick a team"
        },
        "block_id": TEAM_BLOCK_ID,
        "element": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "team"
          },
          "options": team_options(teams),
          "action_id": TEAM_ACTION_ID
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

    def escalation_policy_options(escalation_policies)
      escalation_policies.map do |escalation_policy|
        {
          "text": {
            "type": "plain_text",
            "text": escalation_policy["name"],
          },
          "value": escalation_policy["unique_id"]
        }
      end
    end
  end
end