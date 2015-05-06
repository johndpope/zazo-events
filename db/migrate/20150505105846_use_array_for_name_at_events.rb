class UseArrayForNameAtEvents < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function text_to_text_array(value text)
      returns text[] language sql as $$
          select regexp_split_to_array($1, ':')
      $$;
    SQL
    change_column :events, :name, :string, array: true, using: 'text_to_text_array(name)'
  end

  def down
    execute <<-SQL
      create or replace function text_array_to_text(value text[])
      returns text language sql as $$
          select array_to_string($1, ':')
      $$;
    SQL
    change_column :events, :name, :string, array: false, using: 'text_array_to_text(name)'
  end
end
