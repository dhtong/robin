module Presenters
  class SlackZendutyChannelConfig < BaseChannelConfig
    def initialize(external_accounts, teams)
      super(external_accounts)
      @teams = teams
    end

    def present_team
      res = present
      res[:blocks] << team_select
      res
    end

    private

    def team_select
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a team"
        },
        "block_id": "schedule_source_selection_team-block",
        "accessory": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Service",
          },
          "options": team_options,
          "action_id": "schedule_source_selection_team-action"
        }
      }
    end

    def team_options
      @teams.map do |team|
        {
          "text": {
            "type": "plain_text",
            "text": team["name"],
          },
          "value": team["unique_id"]
        }
      end
    end
  end
end