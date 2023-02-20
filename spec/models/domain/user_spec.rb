require 'rails_helper'

RSpec.describe Domain::User do
  
  describe "#match?" do
    let(:user1) { Domain::User.new({id: 1, email: "dan@supportbots.io", first_name: 'f', last_name: 'l', random: "dd" }) }
    let(:user2) { Domain::User.new({id: "ddd", email: "dan@supportbots.xyz", random: "dd" }) }

    it "match" do
      expect(user1.match?(user2)).to be > 0
    end

    context 'name case' do
      let(:user1) { Domain::User.new({id: 1, email: "dan@supportbots.io", first_name: 'f', last_name: 'l', random: "dd" }) }
      let(:user2) { Domain::User.new({id: "ddd", email: "david@supportbots.xyz", first_name: ' F ', last_name: ' L ' }) }

      it "match" do
        expect(user1.match?(user2)).to be > 0
      end
    end
  end
end
