FactoryBot.define do
  factory :user_contact, class: "Records::UserContact" do
    after_create do |uc|
      uc.customer_users << FactoryBot.create(:customer_user)
    end
  end
end