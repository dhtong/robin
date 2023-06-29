FactoryBot.define do
  factory :support_case_review, class: "Records::SupportCaseReview" do
    association :support_case
    association :reviewer, factory: :customer_user
  end
end