module Slack
  class InteractionHandler
    include ChannelConfigBlocks

    def initialize(customer, slack_client, payload)
      @customer = customer
      @slack_client = slack_client
      @payload = payload
      @interaction = Domain::Slack::Interaction.new(payload)
      @action_registry = Actions::Registry

      @trigger_id = payload["trigger_id"]
      @caller_id = payload["user"]["id"]
      @refresh_home_cmd = Slack::RefreshHome.new(customer, slack_client, @caller_id)
      @channel_config_presenter_class = ::Presenters::Slack::BaseChannelConfig
    end
  
    def execute
      case @payload["type"]
      when "block_actions"
        handle_block_actions
      when "view_submission"
        handle_view_submission
      end
    end
  
    private

    # process modal view submission. this usually results in a (db) state change.
    def handle_view_submission
      case @interaction.view.callback_id
      when "new_integration"
        handle_zenduty_token_submission
      when CHANNEL_CONFIG_CALLBACK_ID
        handle_channel_config
      end
      @refresh_home_cmd.execute
    end

    def handle_channel_config
      state_values = @payload["view"]["state"]["values"]
      channel_id = state_values[CHANNEL_SELECT_BLOCK_ID]["conversations_select-action"]["selected_conversation"]
      escalation_policy_id = state_values[ESCALATION_POLICY_BLOCK_ID][ESCALATION_POLICY_ACTION_ID]["selected_option"]["value"]
      escalation_policy_platform = state_values[PLATFORM_BLOCK_ID][PLATFORM_ACTION_ID]["selected_option"]["value"]

      team_id = state_values[ZENDUTY_TEAM_BLOCK_ID][ZENDUTY_TEAM_ACTION_ID]["selected_option"]["value"] if escalation_policy_platform == "zenduty"

      selected_account_id = @customer.external_accounts.where(platform: escalation_policy_platform).pluck(:id).first
      attributes = {chat_platform: "slack", team_id: team_id, escalation_policy_id: escalation_policy_id, external_account_id: selected_account_id, channel_id: channel_id}
      # a channel can only link to one escalation_policy. this also deletes the history if the user has set a different policy before.
      channel_config = Records::ChannelConfig.unscoped.find_or_initialize_by(channel_id: channel_id, external_account_id: selected_account_id)
      channel_config.update!(chat_platform: "slack", team_id: team_id, escalation_policy_id: escalation_policy_id, disabled_at: nil)
      # channel_config = Records::ChannelConfig.upsert(attributes, unique_by: [:external_account_id, :channel_id])
      subscriber_slack_ids = state_values.dig(SUBSCRIBER_BLOCK_ID, SUBSCRIBER_ACTION_ID, "selected_users")
      subscribers = subscriber_slack_ids&.map do |s_id|
        Records::CustomerUser.find_or_create_by!(customer_id: @customer.id, slack_user_id: s_id)
      end || []
      channel_config.subscribers = subscribers
    end

    # handle an action on slack. this results in a view change.
    def handle_block_actions
      raise StandardError.new("more than one actions") if @payload["actions"].size > 1
      action = @payload["actions"].last

      case action["action_id"]
      when "new_channel_config-action", "add_integration-action"
        action_id = action["action_id"].delete_suffix("-action")
        @action_registry[action_id].execute(@customer, @interaction)
        # presenter = @channel_config_presenter_class.from_external_accounts(@customer.external_accounts)
        # @slack_client.views_open(trigger_id: @trigger_id, view: presenter.present)
      when /_edit_channel_config-action$/
        handle_channel_config_edit(action)
      # when "add_integration-action"
      #   @slack_client.views_open(trigger_id: @trigger_id, view: new_integration_selection)
      when "integration_selection-action"
        handle_integration_selection(action)
      when PLATFORM_ACTION_ID
        handle_escalation_policy_source_selection
      when "escalation_policy_source_selection_team-action"
        handle_escalation_policy_source_selection_team
      end
    end

    def handle_escalation_policy_source_selection_team
      selected_team_id = @payload["actions"][0]["selected_option"]["value"]
      selected_platform = @payload["view"]["state"]["values"][PLATFORM_BLOCK_ID][PLATFORM_ACTION_ID]["selected_option"]["value"]
      selected_account = @customer.external_accounts.where(platform: selected_platform).first
      presenter = Presenters::Slack::ZendutyChannelConfig.from_blocks(@payload["view"]["blocks"])

      available_escalation_policies = selected_account.client.get_escalation_policies(selected_team_id)
      # TODO this validation is not show right now. maybe validate teams before showing team options.
      return ValidationError.new(ZENDUTY_TEAM_BLOCK_ID, "No escalation policies available") if available_escalation_policies.blank?
      presenter.with_escalation_policies(available_escalation_policies)

      @slack_client.views_update(view_id: @payload["view"]["id"], view: presenter.present)
    end

    # integration to use for a channel config
    def handle_escalation_policy_source_selection
      selected_platform = @payload["actions"][0]["selected_option"]["value"]
      selected_account = @customer.external_accounts.where(platform: selected_platform).first

      case selected_platform
      when "zenduty"
        presenter = Presenters::Slack::ZendutyChannelConfig.from_blocks(@payload["view"]["blocks"])
        presenter.with_teams(selected_account.client.get_teams)  
      when "pagerduty"
        presenter = Presenters::Slack::PagerdutyChannelConfig.from_blocks(@payload["view"]["blocks"])
        schedules = selected_account.client.list_schedules
        presenter.with_schedules(schedules)
      end
      
      @slack_client.views_update(view_id: @payload["view"]["id"], view: presenter.present)
    end

    def handle_integration_edit(state_value)
      state_value.each do |action_id, action_value|
        case action_id
        when "integration_edit_zenduty-action"
          p action_value
        end
      end
    end
  
    def handle_zenduty_token_submission
      zenduty_token = @payload.dig("view", "state", "values", ZENDUTY_TOKEN_BLOCK_ID, "zenduty_token-action", "value")
      if zenduty_token != nil
        # TODO prevent duplicates.
        account = Records::ExternalAccount.new(customer: @customer, platform: "zenduty", token: zenduty_token)
        # TODO find a cheaper endpoint
        res = account.client.get_teams
        return ValidationError.new(ZENDUTY_TOKEN_BLOCK_ID, res["error"]) unless res.success?
        account.save!
        Slack::MatchUsersForAccount.perform_later(account.id)
      end
    end
  
    # new integration to add
    def handle_integration_selection(action)
      case action["selected_option"]["value"]
      when "zenduty"
        @slack_client.views_update(view_id: @payload["view"]["id"], view: zenduty_token_input_view)
      when "pagerduty"
        @slack_client.views_update(view_id: @payload["view"]["id"], view: pagerduty_auth_redirect_view(@customer.external_id))
      end
    end

    def new_channel_config
      {
        "type": "modal",
        "callback_id": "new_channel_config",
        "title": {
          "type": "plain_text",
          "text": "Channel config",
        },
        "submit": {
          "type": "plain_text",
          "text": "Submit",
        },
        "blocks": [
          {
            "block_id": "conversations_select-block",
            "type": "input",
            "element": {
              "type": "conversations_select",
              "placeholder": {
                "type": "plain_text",
                "text": "Select channel",
                "emoji": true
              },
              "action_id": "conversations_select-action"
            },
            "label": {
              "type": "plain_text",
              "text": "Channel",
              "emoji": true
            }
          }
        ]
      }
    end

    ZENDUTY_TOKEN_BLOCK_ID = "zenduty_token-block"
  
    # todo move this to presenters
    def zenduty_token_input_view
      view = new_integration_selection
      view[:submit] = {"type": "plain_text", "text": "Submit", "emoji": true}
      token_block = {
        "block_id": ZENDUTY_TOKEN_BLOCK_ID,
        "type": "input",
        "element": {
          "type": "plain_text_input",
          "action_id": "zenduty_token-action"
        },
        "label": {
          "type": "plain_text",
          "text": "Access token",
          "emoji": true
        }
      }
      view[:blocks] << token_block
      view
    end

     # todo move this to presenters
    def pagerduty_auth_redirect_view(external_id)
      view = new_integration_selection
      view[:submit] = {"type": "plain_text", "text": "Done", "emoji": true}
      url = "https://identity.pagerduty.com/oauth/authorize?client_id=8bded887-2b85-4e2a-85a3-7ef758afb8ae&redirect_uri=#{Pagerduty::OauthClient.get_redirect_uri(external_id)}&scope=read&response_type=code"
      token_block = {
        "block_id": Presenters::Slack::Integration::PAGERDUTY_AUTH_BLOCK_ID,
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "This button will redirect you to pagerduty to give this app access"
        },
        "accessory": {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "Redirect",
            "emoji": true
          },
          "value": "pd_redirect",
          "url": url,
          "action_id": "button-action"
        }
      }
      view[:blocks] << token_block
      view
    end

    INTEGRATION_OPTIONS = %w[zenduty pagerduty]

    def new_integration_selection
      existing_options = @customer.external_accounts.pluck(:platform)
      available_options = INTEGRATION_OPTIONS - existing_options
      if available_options.empty?
        return Presenters::Slack::Integration.no_integrations_available
      end
      Presenters::Slack::Integration.new_integration_selection(available_options)
    end

    # this change db state
    # this is the overflow menu
    def handle_channel_config_edit(action)
      case action["selected_option"]["value"]
      when "delete"
        channel_config_id = action["action_id"].scan(/^\d+/).first.to_i
        Records::ChannelConfig.where(id: channel_config_id).update_all(disabled_at: Time.current)
      end
      @refresh_home_cmd.execute
    end
  end
end
