class Slack::InteractionsController < ApplicationController
  def create
    handler = Slack::InteractionHandler.new(customer, Slack::Web::Client.new, payload)
    res = handler.execute
    if res.is_a? Slack::ValidationError
      return render json: { response_action: "errors", errors: res.to_json }
    end
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
