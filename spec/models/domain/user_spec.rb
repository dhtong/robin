require 'rails_helper'

RSpec.describe Domain::User do
  
  describe "#match?" do
    let(:user1) { described_class.new({id: 1, email: "dan@supportbots.io", first_name: 'f', last_name: 'l', random: "dd" }) }
    let(:user2) { described_class.new({id: 1, email: "dan@supportbots.xyz", first_name: 'f', last_name: 'l', random: "dd" }) }

    it "match" do
      expect(user1.match?(user2)).to eq 8
    end
  end
end
