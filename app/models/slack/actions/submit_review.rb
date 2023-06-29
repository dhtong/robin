module Slack::Actions
  class SubmitReview

    def initialize
    end

    def execute(customer, interaction, payload)
      review_id = interaction.actions[0].block_id.partition("-submit_review-block")[0]

      resolved = payload.dig("state", "values", "#{review_id}-resolution_review-block", "submit_review-action", "value") == "true"
      satisfication = payload.dig("state", "values", "#{review_id}-satisfication_review-block", "submit_review-action", "value")

      Records::SupportCaseReview.update(review_id, resolved: resolved, satisfication: satisfication, status: :submitted)

      submitted_blocks = payload["message"]["blocks"]
      submitted_blocks[-1] = Presenters::Slack::SupportCaseReview.new.present_submitted
      customer.slack_client.chat_update(channel: payload["channel"]["id"], ts: payload["message"]["ts"], blocks: submitted_blocks)
    end
  end
end