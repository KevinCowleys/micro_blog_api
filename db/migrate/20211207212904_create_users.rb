class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, unique: true
      t.string :password_digest, null: false
      t.string :name
      t.string :email, unique: true, null: false
      t.string :phone
      t.boolean :verified
      t.string :location
      t.string :gender
      t.datetime :birth_date
      t.string :website
      t.string :bio

      t.timestamps
    end
  end
end
