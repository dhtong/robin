module Domain
  class OncallUser
    extend Forwardable

    def_delegators :@source, :first_name, :last_name, :email

    def self.from_pd(h)
      n = h["name"].split(" ")
      h["first_name"] = n.first
      h["last_name"] = n.last
      new(h)
    end


    def initialize(h)
      @source = RecursiveOpenStruct.new(h)
    end
  end
end