class CreateSupportCaseReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :support_case_reviews do |t|
      t.references :support_case, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: {to_table: :customer_users}

      t.string :status
      t.boolean :resolved
      t.integer :satisfication 
      t.timestamps
    end

    remove_column :support_cases, :instigator_message_id, :bigint
    add_reference :support_cases, :instigator_message, foreign_key: {to_table: :messages}
    add_reference :messages, :customer_user
    add_index :customer_users, :slack_user_id
  end
end
