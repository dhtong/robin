module Slack
  module Submissions
    class Registry
      extend Dry::Container::Mixin
      include ChannelConfigBlocks

      register "new_integration", -> { ZendutyToken.new }
      register CHANNEL_CONFIG_CALLBACK_ID, -> { ChannelConfig.new }
    end
  end
end