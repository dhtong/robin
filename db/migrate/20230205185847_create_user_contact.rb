class CreateUserContact < ActiveRecord::Migration[7.0]
  def change
    create_table :user_contacts do |t|
      t.references :customer_user, null: false, foreign_key: true

      t.string :method
      t.string :number, index: true
      t.timestamps
    end
  end
end
