FactoryBot.define do
  factory :user_contact, class: "Records::UserContact" do
    # after(:build) do |uc|
    #   uc.customer_users << FactoryBot.build(:customer_user)
    # end
    transient do
      customer_users { [] }
    end

    after(:create) do |uc, evaluator|
      if evaluator.customer_users.any?
        uc.customer_users << evaluator.customer_users
      else
        uc.customer_users << FactoryBot.create(:customer_user)
      end
    end
  end
end