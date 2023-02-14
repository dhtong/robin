FactoryBot.define do
  factory :user_contact_association, class: "Records::UserContactAssociation" do
    association :customer_user
    association :user_contact
  end
end