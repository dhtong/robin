class CreateCustomerUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_users do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :email, index: true
      t.string :slack_user_id

      t.timestamps
    end
  end
end
