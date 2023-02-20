module Pagerduty
  class ApiClient
    USER_PAGE_LIMIT = 100

    def initialize(access_token)
      @api_conn = Faraday.new(
        url: "https://api.pagerduty.com",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer #{access_token}",
          "Accept": "application/vnd.pagerduty+json;version=2"
        }
      )
    end

    def list_schedules
      res = @api_conn.get("/schedules")
      # not handling errors. this is a silent fail
      return [] unless res.success?
      # not handle pagination
      JSON.parse(res.body)["schedules"]
    end

    def list_users
      fetch = true
      offset = 0
      users = []
      while fetch
        res = json_body { @api_conn.get("/users", { offset: offset, limit: USER_PAGE_LIMIT } ) }
        users += res["users"].map { |u| Domain::User.from_pd(u) }
        offset += res["users"].size
        fetch = res["more"]
      end
      users
    end

    def get_oncall(schedule_id)
      res = @api_conn.get("/oncalls", { schedule_ids: [schedule_id], include: ["users"]})
      return nil unless res.success?
      res_body = JSON.parse(res.body)
      return [] if res_body["oncalls"].empty?
      res_body["oncalls"].map { |oncall| oncall["user"] }
    end

    def get_user(id)
      res = @api_conn.get("/users/#{id}")
      return nil unless res.success?
      res_body = JSON.parse(res.body)
      Domain::User.from_pd(res_body["user"])
    end

    private

    def json_body
      res = yield
      return unless res.success?
      JSON.parse(res.body)
    end
  end
end