module Zenduty
  class Client
    extend Forwardable

    attr_reader :api_token # For testing in `rails c`

    def_delegators :@team_api, :get_teams, :get_team_details
    def_delegators :@schedule_api, :get_schedules
    def_delegators :@escalation_policies_api, :get_escalation_policies

    def initialize(api_token)
      @api_token = api_token

      @api_client = ::Zenduty::APIClient.new(@api_token)
      @team_api = ::Zenduty::TeamsApi.new(@api_token)
      @schedule_api = ::Zenduty::SchedulesApi.new(@api_token)
      @escalation_policies_api = ::Zenduty::EscalationPoliciesApi.new(@api_token)
    end

    def oncall(team_id)
      # Not supported by the zenduty gem, so we call the URL directly ourselves.
      # https://apidocs.zenduty.com/#tag/OnCall
      #
      # TODO(alec): Upstream fix?
      @api_client._get("/api/account/teams/#{team_id}/oncall")
    end

    def get_user(team_id, member_username)
      # unfortunately zenduty member id is not exposed in other zenduty endpoints
      users_res = @api_client._get("/api/account/teams/#{team_id}/members")
      return unless users_res.success?
      users_res.each do |u|
        if u["user"]["username"] == member_username
          return Domain::User.new(u["user"])
        end
      end
      return nil
    end
  end
end