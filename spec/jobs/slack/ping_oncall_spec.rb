require 'rails_helper'

RSpec.describe Slack::PingOncall, type: :job do
  include ActiveJob::TestHelper
  
  describe "#perform_later" do
    let(:message) { create(:message) }
    let(:stub_slack) { stub_request(:post, /slack/).to_return(status: 200, body: "", headers: {}) }

    subject { described_class.perform_later(message.id) }

    it "uploads a backup" do
      stub_slack
      perform_enqueued_jobs { subject }
    end
  end
end
