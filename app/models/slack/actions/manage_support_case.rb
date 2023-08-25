module Slack::Actions
  class ManageSupportCase

    def initialize
      @refresh_home_cmd_clz = ::Slack::RefreshHome
      @start_review_job = ::Slack::StartSupportCaseReview
    end

    def execute(customer, interaction, _payload)
      action = interaction.actions[0]
      case_id = action.block_id.scan(/^\d+/).first.to_i

      case action.selected_option.value
      when "request_feedback"
        @start_review_job.perform_later(case_id)
      end
      @refresh_home_cmd_clz.new(
        customer_id: customer.id,
        caller_id: interaction.user.id
      ).execute
    end
  end
end