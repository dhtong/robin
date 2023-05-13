module Domain
  module Slack
    class Action < Dry::Struct
      class Option < Dry::Struct
        transform_keys(&:to_sym)

        attribute :value, Types::String
      end

      transform_keys(&:to_sym)

      attribute :type, Types::String
      attribute :block_id, Types::String
      attribute :action_id, Types::String

      # other types of action might not have select_option
      attribute :selected_option?, Option
    end
  end
end
