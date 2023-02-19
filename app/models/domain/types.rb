module Domain
  Dry::Types.load_extensions(:maybe)

  module Types
    include Dry.Types

    Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  end
end