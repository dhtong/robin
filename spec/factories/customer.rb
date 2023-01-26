FactoryBot.define do
  factory :customer, class: "Records::Customer" do
    slack_team_id { Faker::Code.npi }
  end
end