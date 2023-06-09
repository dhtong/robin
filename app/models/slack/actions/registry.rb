module Slack::Actions
  class Registry
    extend Dry::Container::Mixin

    register "new_channel_config", -> { NewChannelConfig.new }
    register "add_integration", -> { AddIntegration.new }
    register "integration_selection", -> { SelectIntegration.new }
    register "escalation_policy_source_selection", -> { SelectEscalationPolicySource.new }
  end
end