class CreateExternalAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :external_accounts do |t|
      t.string :platform
      t.string :external_id
      t.references :customer, null: false, foreign_key: true
      t.string :token
      t.string :refresh_token

      t.timestamps
    end
  end
end
