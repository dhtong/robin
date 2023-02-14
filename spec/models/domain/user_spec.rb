require 'rails_helper'

RSpec.describe Domain::User do
  
  describe "#match?" do
    let(:user1) { described_class.new({"email": "dan@supportbots.io" }) }
    let(:user2) { described_class.new({"email": "dan@supportbots.xyz" }) }

    it "match" do
      expect(user1.match?(user2)).to be true
    end
  end
end
