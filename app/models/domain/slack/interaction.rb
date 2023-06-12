module Domain
  module Slack
    class Interaction < Dry::Struct
      class User < Dry::Struct
        transform_keys(&:to_sym)
        attribute :id, Types::String
      end

      transform_keys(&:to_sym)

      attribute :trigger_id?, Types::String
      attribute :view, View
      attribute :actions?, Types.Array(Action)
      attribute :user?, User
    end
  end
end
