FactoryBot.define do
  factory :external_account, class: "Records::ExternalAccount" do
    token { Faker::Crypto.md5 }
    association :customer
  end
end