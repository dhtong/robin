module Pagerduty
  class OauthClient
    AUTH_URI = "https://supportbots.herokuapp.com/pagerduty/auth"

    def self.get_redirect_uri(customer_external_id)
      "#{AUTH_URI}?external_id=#{customer_external_id}"
    end

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
      @oauth_conn = Faraday.new(
        url: "https://identity.pagerduty.com",
        headers: {'Content-Type' => 'application/json'}
      )
    end

    def oauth(code, customer_external_id)
      body = {
        grant_type: :authorization_code,
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: self.class.get_redirect_uri(customer_external_id),
        code: code
      }
      @oauth_conn.post("/oauth/token", body.to_json, "Content-Type" => "application/json")
    end
  end
end