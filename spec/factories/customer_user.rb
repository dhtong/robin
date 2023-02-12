FactoryBot.define do
  factory :customer_user, class: "Records::CustomerUser" do
    after_create do |cu|
      cu.customers << FactoryBot.create(:customer)
    end
  end
end