module Slack::Actions
  class Registry
    extend Dry::Container::Mixin

    register "new_channel_config", -> { NewChannelConfig.new }
  end
end