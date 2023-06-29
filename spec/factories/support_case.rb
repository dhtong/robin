FactoryBot.define do
  factory :support_case, class: "Records::SupportCase" do
    association :customer
    association :instigator_message, factory: :message
    channel_id { Faker::Alphanumeric.alphanumeric }
  end
end