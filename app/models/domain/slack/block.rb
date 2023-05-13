module Domain
  module Slack
    class Block < Dry::Struct
      class Element < Dry::Struct
        attribute :type, Types::String
        attribute :action_id, Types::String
      end

      transform_keys(&:to_sym)

      attribute :type, Types::String
      attribute :block_id, Types::String
      attribute :element?, Element

      alias_method :id, :block_id
    end
  end
end
