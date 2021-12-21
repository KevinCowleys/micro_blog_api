class CreateMutes < ActiveRecord::Migration[6.1]
  def change
    create_table :mutes do |t|
      t.references :muted, foreign_key: { to_table: :users }
      t.references :muted_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
