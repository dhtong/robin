require "rails_helper"

RSpec.describe "Event", type: :request do
  it 'success' do
    post "/telegram/events"
    expect(response).to have_http_status(:ok)
  end
end