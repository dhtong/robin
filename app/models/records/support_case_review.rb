module Records
  class SupportCaseReview < ApplicationRecord
    belongs_to :support_case
    belongs_to :reviewer, class_name: "Records::CustomerUser"
  end
end
