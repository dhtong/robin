module Domain
  module Slack
    class Interaction < Dry::Struct
      transform_keys(&:to_sym)

      attribute :view, View
      attribute :actions?, Types.Array(Action)
    end
  end
end
