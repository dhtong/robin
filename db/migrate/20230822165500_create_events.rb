class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :platform
      t.jsonb :event
      t.string :external_id, index: { unique: true }

      t.references :message      
      t.timestamps
    end
  end
end
