module Commands
  class CreateSupportCase
    # only auto create a new case, if the previous case is in a separate thread and there is no new cases in this window
    CASE_AUTO_CREATION_WINDOW = 1.hour.ago

    def execute(event_id:)
      event = Records::Event.includes(:message).find(event_id)
      message = event.message
      return if Records::SupportCase.find_by(channel_id: message.channel_id, slack_ts: message.slack_ts)
      return if Records::SupportCase.where(channel_id: message.channel_id).where("created_at > ?", CASE_AUTO_CREATION_WINDOW).any?
      Records::SupportCase.create!(instigator_message_id: message.id, channel_id: message.channel_id, slack_ts: message.slack_ts, customer_id: message.customer_id)
    end
  end
end