FactoryBot.define do
  factory :customer, class: "Records::Customer" do
    slack_team_id { Faker::Code.npi }
    slack_access_token { Faker::Crypto.md5 }
  end
end