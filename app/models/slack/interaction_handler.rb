module Slack
  class InteractionHandler
    include ChannelConfigBlocks

    def initialize(customer, slack_client, payload)
      @customer = customer
      @slack_client = slack_client
      @payload = payload
      @interaction = Domain::Slack::Interaction.new(payload)
      @action_registry = Actions::Registry
      @submission_registry = Submissions::Registry

      @trigger_id = payload["trigger_id"]
      @caller_id = payload["user"]["id"]
      @refresh_home_cmd = Slack::RefreshHome.new(customer_id: customer.id, caller_id: @caller_id)
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
      @submission_registry[@interaction.view.callback_id].execute(@customer, @interaction, @payload)
      @refresh_home_cmd.execute
    end

    # handle an action on slack. this results in a view change.
    def handle_block_actions
      raise StandardError.new("more than one actions") if @payload["actions"].size > 1
      action = @payload["actions"].last

      action_id = action["action_id"].delete_suffix("-action")
      @action_registry[action_id].execute(@customer, @interaction, @payload)
    end
  end
end
