module Zenduty
  class Client
    extend Forwardable

    def_delegators :@team_api, :get_teams, :get_team_details
    def_delegators :@schedule_api, :get_schedules

    def initialize(api_token)
      @api_token = api_token
      @team_api = ::Zenduty::TeamsApi.new(@api_token)
      @schedule_api = ::Zenduty::SchedulesApi.new(@api_token)
    end
  end
end