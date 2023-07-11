module Commands
  class StartSupportCaseReview
    def initialize
      @presenter = Presenters::Slack::SupportCaseReview.new
    end

    def execute(case_id:)
      return if Records::SupportCaseReview.find_by(support_case_id: case_id)
      @support_case = Records::SupportCase.includes({instigator_message: :customer_user} , :customer).find(case_id)
      @reviewer = @support_case.instigator_message.customer_user
      # early return if it's an internal case
      return if @reviewer.customer == @support_case.instigator_message.customer
      ActiveRecord::Base.transaction do
        r = create_review
        post_message(case_id, r.id)
      end
    end

    private

    def create_review
      Records::SupportCaseReview.create!(status: "requested", support_case: @support_case, reviewer: @reviewer)
    end

    def post_message(case_id, review_id)
      external_url = @support_case.instigator_message.external_url || get_instigator_message_link
      blocks = @presenter.present(review_id: review_id, slack_user_id: @reviewer.slack_user_id, message_link: external_url).to_json
      @support_case.customer.slack_client.chat_postMessage(channel: @reviewer.slack_user_id, blocks: blocks, as_user: true)
    end

    def get_instigator_message_link
      msg = @support_case.instigator_message
      @support_case.customer.slack_client.chat_getPermalink(channel: msg.channel_id, message_ts: msg.event_payload["ts"])['permalink']
    end
  end
end