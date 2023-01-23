module Pagerduty
  class Client
    AUTH_URI = "https://supportbots.herokuapp.com/pagerduty/auth"

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
      @oauth_conn = Faraday.new(url: "https://identity.pagerduty.com/oauth/token")
    end

    def oauth(code)
      body = {
        grant_type: :authorization_code,
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: AUTH_URI,
        code: code
      }
      @oauth_conn.post("post", body.to_json, "Content-Type" => "application/json")
    end
  end
end