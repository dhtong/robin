class Slack::StartSupportCaseReview < ApplicationJob
  queue_as :default

  def perform(case_id)
    Commands::StartSupportCaseReview.new.execute(case_id: case_id)
  end
end
