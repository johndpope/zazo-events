class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, index: true
      t.datetime :triggered_at, limit: 3, index: true
      t.string :triggered_by
      t.string :initiator, index: true
      t.string :initiator_id, index: true
      t.string :target, index: true
      t.string :target_id, index: true
      t.json :data
      t.json :raw_params

      t.timestamps null: false, limit: 3
    end
  end
end
