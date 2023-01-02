class Slack::InteractionsController < ApplicationController
  def create
    handler = Slack::InteractionHandler.new(customer, Slack::Web::Client.new, payload)
    handler.execute
    head :ok
  end

  private

  def customer
    Customer.find_by(slack_team_id: payload["team"]["id"])
  end

  def payload
    @payload ||= JSON.parse(params[:payload])
  end
end
