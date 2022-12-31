require "rails_helper"

RSpec.describe "Event", type: :request do
  it "challenge" do
    challenge_message = 'sss'
    post "/slack/events", params: { challenge: challenge_message }

    response_body = JSON.parse(response.body)
    expect(response_body['challenge']).to eq challenge_message
    expect(response).to have_http_status(:ok)
  end
end