FactoryBot.define do
  factory :external_account do
    token { Faker::Crypto.md5 }
    association :customer
  end
end