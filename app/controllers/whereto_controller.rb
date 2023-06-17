require "httparty"

class WheretoController < ApplicationController
  # location
  def index
    response_url = params[:response_url]
  
    body = { text: "Try McDonald's!" }

    HTTParty.post(response_url, body: body, headers: {'Content-Type' => 'application/json'})
  end
end
