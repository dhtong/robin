require 'rails_helper'

RSpec.describe Domain::Slack::Interaction do
  describe "#initialize" do
    let(:view) do
      {
        "id": "V057AMA75MY",
        "team_id": "T04FZQN3B9D",
        "type": "modal",
        "blocks": [
          {
            "type": "input",
            "block_id": "conversations_select-block",
            "label": {
              "type": "plain_text",
              "text": "Channel",
              "emoji": true
            },
            "optional": false,
            "dispatch_action": false,
            "element": {
              "type": "conversations_select",
              "action_id": "conversations_select-action",
              "placeholder": {
                "type": "plain_text",
                "text": "Select channel",
                "emoji": true
              },
              "filter": {
                "include": [
                  "public",
                  "private"
                ],
                "exclude_bot_users": true
              }
            }
          },
          {
            "type": "section",
            "block_id": "multi_subscribers_select-block",
            "text": {
              "type": "mrkdwn",
              "text": "[optional] Subscribers to always get a private ping",
              "verbatim": false
            },
            "accessory": {
              "type": "multi_users_select",
              "action_id": "multi_subscribers_select-action",
              "placeholder": {
                "type": "plain_text",
                "text": "Select",
                "emoji": true
              }
            }
          }
        ],
        "callback_id": "new_channel_config",
        "state": {
          "values": {
            "conversations_select-block": {
              "conversations_select-action": {
                "type": "conversations_select",
                "selected_conversation": "C04GT0GUEBT"
              }
            },
            "multi_subscribers_select-block": {
              "multi_subscribers_select-action": {
                "type": "multi_users_select",
                "selected_users": [
                  "U04G7NZTHKQ"
                ]
              }
            }
          }
        },
        "submit": {
          "type": "plain_text",
          "text": "Submit",
          "emoji": true
        }
      }
    end
    let(:payload) do
      {
        "view": view,
        "actions": [
          {
            "type": "static_select",
            "action_id": "escalation_policy_source_selection_team-action",
            "block_id": "escalation_policy_source_selection_team-block",
            "selected_option": {
              "text": {
                "type": "plain_text",
                "text": "Operations Team(Sample)",
                "emoji": true
              },
              "value": "47975507-d54d-42d5-8d31-622653bd2360"
            },
            "placeholder": {
              "type": "plain_text",
              "text": "team",
              "emoji": true
            },
            "action_ts": "1683810749.028916"
          }
        ]
      }
    end

    it 'init' do
      intr = described_class.new(payload)
      expect(intr.view.blocks.count).to eq 2
      expect(intr.view.blocks[1].element).to be_nil
      expect(intr.view.blocks[0].element.type).not_to be_blank
      expect(intr.view.blocks[0].id).to eq intr.view.blocks[0].block_id
    end
  end
end
