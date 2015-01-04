class CreateReposts < ActiveRecord::Migration
  def change
    create_table :reposts do |t|
      t.integer :micropost_id
      t.integer :reposter_id

      t.timestamps null: false
    end
    add_index :reposts, :micropost_id
    add_index :reposts, :reposter_id
    add_index :reposts, [:micropost_id, :reposter_id], unique: true
  end
end
