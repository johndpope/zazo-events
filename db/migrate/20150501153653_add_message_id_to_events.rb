class AddMessageIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :message_id, :uuid
    add_index :events, :message_id
  end
end
