module Domain
  class User < Dry::Struct
    attribute :id, Types::Coercible::String
    attribute :email, Types::Email.optional
    attribute :first_name, Types::String.optional
    attribute :last_name, Types::String.optional

    class << self
      def from_pd(h)
        clean_email(h)
        new(set_names(h))
      end

      def from_slack(member_h)
        h = member_h["profile"]
        h["id"] = member_h["id"]
        clean_email(h)
        new(h)
      end

      private

      def clean_email(h)
        h["email"] = h["email"]&.downcase.strip
      end

      def set_names(h)
        n = h["name"].split(" ")
        h["first_name"] = n.first
        h["last_name"] = n.last
        h
      end
    end

    # get everything before the last .
    @@company_email_regex = /^(?<company_email>.*)[\.]/

    # match? returns matching score. 10 is the higest
    def match?(other)
      return 10 if self.email == other.email
      return 8 if self.email.present? && self.email&.match(@@company_email_regex)[:company_email] == other.email&.match(@@company_email_regex)[:company_email]
      return 5 if self.first_name.present? && self.last_name.present? && self.first_name == other.first_name && self.last_name == other.last_name
      return 0
    end
  end
end
