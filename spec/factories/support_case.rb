FactoryBot.define do
  factory :support_case, class: "Records::SupportCase" do
    association :customer
    channel_id { Faker::Alphanumeric.alphanumeric }
  end
end