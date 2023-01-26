module Pagerduty
  class ApiClient
    def initialize(access_token)
      @oauth_conn = Faraday.new(
        url: "https://api.pagerduty.com",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer #{access_token}",
          "Accept": "application/vnd.pagerduty+json;version=2"
        }
      )
    end

    def list_schedules
      res = @oauth_conn.get("/schedules")
      # not handling errors. this is a silent fail
      return [] unless res.success?
      # not handle pagination
      JSON.parse(res.body)["schedules"]
    end
  end
end