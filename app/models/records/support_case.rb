module Records
  class SupportCase < ApplicationRecord
    belongs_to :customer
    belongs_to :instigator_message, class_name: "Records::Message", optional: true
  end
end
