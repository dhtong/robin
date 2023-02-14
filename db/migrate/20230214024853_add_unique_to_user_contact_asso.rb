class AddUniqueToUserContactAsso < ActiveRecord::Migration[7.0]
  def change
    add_index :user_contact_associations, [:user_contact_id, :customer_user_id], unique: true, name: :idx_user_contact_assoc_unique
  end
end
