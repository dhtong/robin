module Domain
  class User < Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::Coercible::String
    attribute :email?, Types::String
    attribute :first_name?, Types::String
    attribute :last_name?, Types::String

    class << self
      def from_pd(h)
        new(set_names(h))
      end

      def from_zd(h)
        user_h = h["user"]
        user_h["id"] = h["unique_id"]
        new(user_h)
      end

      def from_slack(member_h)
        h = member_h["profile"]
        h["id"] = member_h["id"]
        new(h)
      end

      private

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
      return 5 if self.first_name.present? && self.last_name.present? && clean_name(self.first_name) == clean_name(other.first_name) && clean_name(self.last_name) == clean_name(other.last_name)
      return 0
    end

    private

    def clean_name(n)
      n&.strip&.downcase
    end
  end
end
