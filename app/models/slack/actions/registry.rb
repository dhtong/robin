module Slack::Actions
  class Registry
    extend Dry::Container::Mixin

    class Noop
      def execute(*args)
      end
    end

    register "new_channel_config", -> { NewChannelConfig.new }
    register "edit_channel_config", -> { EditChannelConfig.new }
    register "manage_support_case", -> { ManageSupportCase.new }
    register "add_integration", -> { AddIntegration.new }
    register "edit_integration", -> { EditIntegration.create }
    register "integration_selection", -> { SelectIntegration.new }
    register "escalation_policy_source_selection", -> { SelectEscalationPolicySource.new }
    register "escalation_policy_source_selection_team", -> { SelectEscalationPolicyTeam.new }

    register "submit_review", -> { SubmitReview.new }

    # slack button only comes with section block, which always disaptch_action, even though we might not need it.
    register "noop", -> { Noop.new }
  end
end