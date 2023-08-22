FactoryBot.define do
  factory :channel_config, class: "Records::ChannelConfig" do
    association :external_account

    channel_id { Faker::Crypto.md5 }
  end
end