module Presenters::Slack
  class SupportCaseReview
    def present(review_id:, slack_user_id:, message_link:)
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":wave: <@#{slack_user_id}> , regarding your <#{message_link}|issue>..."
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "input",
          "label": {
            "type": "plain_text",
            "text": "Was it resolved?"
          },
          "block_id": "#{review_id}-resolution_review-block",
          "element": {
            "type": "static_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Select",
              "emoji": true
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "text": "Yes"
                },
                "value": "yes"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "No"
                },
                "value": "no"
              }
            ],
            "action_id": "resolution_review-action"
          }
        },
        {
          "type": "input",
          "label": {
            "type": "plain_text",
            "text": "How was your experience?"
          },
          "block_id": "#{review_id}-satisfication_review-block",
          "element": {
            "type": "static_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Select",
              "emoji": true
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": ":smiley:"
                },
                "value": "10"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": ":neutral_face:"
                },
                "value": "5"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": ":white_frowning_face:"
                },
                "value": "0"
              }
            ],
            "action_id": "satisfication_review-action"
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "actions",
          "block_id": "#{review_id}-submit_review-block",
          "elements": [
            {
              "type": "button",
              "action_id": "submit_review-action",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "Submit"
              },
              "value": "submit",
              "style": "primary"
            }
          ]
        }
      ]
    end

    def present_submitted
      {
        "type": "context",
        "elements": [
          {
            "type": "plain_text",
            "text": "Thank you for your feedback!",
            "emoji": true
          }
        ]
      }
    end
  end
end
