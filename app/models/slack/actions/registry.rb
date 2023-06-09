module Slack::Actions
  class Registry
    extend Dry::Container::Mixin

    register "new_channel_config", -> { NewChannelConfig.new }
    register "add_integration", -> { AddIntegration.new }
    register "select_integration", -> { SelectIntegration.new }
    register "select_escalation_policy_source", -> { SelectEscalationPolicySource.new }
  end
end