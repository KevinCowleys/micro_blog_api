class CreatePostSaveds < ActiveRecord::Migration[6.1]
  def change
    create_table :post_saveds do |t|
      t.belongs_to :post, null: false, foreign_key: { to_table: :posts }
      t.belongs_to :user, null: false, foreign_key: { to_table: :posts }

      t.timestamps
    end
  end
end
