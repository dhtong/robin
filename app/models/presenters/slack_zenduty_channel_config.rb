module Presenters
  class SlackZendutyChannelConfig
    CALLBACK_ID = "new_channel_config"
    BASE_VIEW = {
      "type": "modal",
      "callback_id": CALLBACK_ID,
      "title": {
        "type": "plain_text",
        "text": "Channel config"
      }
    }
    SUBMIT_BUTTON = {
      "type": "plain_text",
      "text": "Submit"
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
    PLATFORM_BLOCK_ID = "escalation_policy_source_selection-block"
    PLATFORM_ACTION_ID = "escalation_policy_source_selection-action"
    TEAM_BLOCK_ID = "escalation_policy_source_selection_team-block"
    TEAM_ACTION_ID = "escalation_policy_source_selection_team-action"
    ESCALATION_POLICY_BLOCK_ID = "escalation_policy_source_selection_team_escalation_policy-block"
    ESCALATION_POLICY_ACTION_ID = "escalation_policy_source_selection_team_escalation_policy-action"

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
            "text": "Pick a service to get an escalation policy from"
          },
          "block_id": PLATFORM_BLOCK_ID,
          "accessory": {
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
      view[:submit] = SUBMIT_BUTTON
      view[:blocks] = @blocks
      view
    end

    def with_teams(teams)
      @blocks[2] = team_block(teams)
    end

    def with_escalation_policies(escalation_policies)
      if @blocks.length < 3
        return raise StandardError
      end
      @blocks[3] = escalation_policy_block(escalation_policies)
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