module Domain
  class User
    extend Forwardable

    # TODO fix forwarding to private method RecursiveOpenStruct#first_name
    def_delegators :@source, :first_name, :last_name, :email, :id

    class << self
      def from_pd(h)
        new(set_names(h))
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


    def initialize(h)
      @source = RecursiveOpenStruct.new(h)
    end

    # get everything before the last .
    @@company_email_regex = /^(?<company_email>.*)[\.]/

    def match?(other)
      return true if self.email == other.email
      return true if self.email.match(@@company_email_regex)[:company_email] == other.email.match(@@company_email_regex)[:company_email]
      return true if self.first_name == other.first_name && self.last_name == other.last_name
    end
  end
end
