FactoryBot.define do
  factory :message, class: "Records::Message" do
    association :customer
    channel_id { Faker::Alphanumeric.alphanumeric }
  end
end