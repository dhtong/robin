module Domain
  module Slack
    class Block < Dry::Struct
      class Text < Dry::Struct
        transform_keys(&:to_sym)

        attribute :type, Types::String
        attribute :text, Types::String
        attribute :emoji, Types::Bool
      end

      class Element < Dry::Struct
        transform_keys(&:to_sym)

        attribute :type, Types::String
        attribute :action_id, Types::String
        attribute :placeholder?, Text
      end

      transform_keys(&:to_sym)

      attribute :type, Types::String
      attribute :block_id, Types::String
      attribute :label?, Text
      attribute :element?, Element
      attribute :dispatch_action?, Types::Bool
      attribute :optional?, Types::Bool

      alias_method :id, :block_id
    end
  end
end
