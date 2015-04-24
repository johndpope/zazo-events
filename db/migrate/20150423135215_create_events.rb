class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :triggered_at, limit: 3
      t.string :triggered_by
      t.string :initiator
      t.string :initiator_id
      t.string :target
      t.string :target_id
      t.text :data
      t.text :raw_params

      t.timestamps null: false
    end

    add_index :events, :name
    add_index :events, :triggered_at
    add_index :events, :initiator
    add_index :events, :initiator_id
    add_index :events, :target
    add_index :events, :target_id
  end
end
