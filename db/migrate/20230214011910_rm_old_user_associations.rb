class RmOldUserAssociations < ActiveRecord::Migration[7.0]
  def change
    remove_reference :user_contacts, :customer_user, index: true, foreign_key: true
  end
end
