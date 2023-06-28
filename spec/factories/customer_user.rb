FactoryBot.define do
  factory :customer_user, class: "Records::CustomerUser" do
    association :customer
    # after(:build) do |cu|
    #   cu.user_contacts << FactoryBot.build(:user_contact)
    # end
    slack_user_id { Faker::Code.npi }

    transient do
      user_contacts { [] }
    end

    after(:create) do |cu, evaluator|
      cu.user_contacts << evaluator.user_contacts
    end
  end
end