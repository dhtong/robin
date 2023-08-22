FactoryBot.define do
  factory :event, class: "Records::Event" do
    association :message
    event { {ts: "12312312.22"} }
    external_id { Faker::Crypto.md5 }
  end
end