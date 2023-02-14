class CreateUserContactAssociations < ActiveRecord::Migration[7.0]
  def change
    create_table :user_contact_associations do |t|
      t.references :user_contact, null: false, foreign_key: true
      t.references :customer_user, null: false, foreign_key: true
      t.string :status
      t.timestamps
    end
  end
end
