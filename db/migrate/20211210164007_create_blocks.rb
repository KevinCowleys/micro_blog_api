class CreateBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :blocks do |t|
      t.references :blocked, foreign_key: { to_table: :users }
      t.references :blocked_by, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
