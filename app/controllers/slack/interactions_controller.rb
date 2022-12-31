class Slack::InteractionsController < ApplicationController
  def create
    p params
    head :ok
  end
end
