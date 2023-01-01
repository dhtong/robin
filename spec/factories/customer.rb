FactoryBot.define do
  factory :customer do
    slack_team_id { Faker::Code.npi }
  end
end