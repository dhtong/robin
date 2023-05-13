module Domain
  module Slack
    class View < Dry::Struct
      transform_keys(&:to_sym)

      attribute :id, Types::String
      attribute :blocks, Types.Array(Block)
    end
  end
end
