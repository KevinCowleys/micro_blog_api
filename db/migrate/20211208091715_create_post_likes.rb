class CreatePostLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :post_likes do |t|
      t.belongs_to :post, null: false, foreign_key: { to_table: :posts }
      t.belongs_to :user, null: false, foreign_key: { to_table: :posts }

      t.timestamps
    end
  end
end
