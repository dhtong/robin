FactoryBot.define do
  factory :channel_config, class: "Records::ChannelConfig" do
    association :external_account
  end
end