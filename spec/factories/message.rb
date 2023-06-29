FactoryBot.define do
  factory :message, class: "Records::Message" do
    association :customer
    association :customer_user
    channel_id { Faker::Alphanumeric.alphanumeric }
    event_payload { {ts: "12312312.22"} }
  end
end