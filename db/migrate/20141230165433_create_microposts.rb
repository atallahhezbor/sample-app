class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, index: true

      t.timestamps null: false
    end
    add_index :microposts, [:user_id, :created_at] #multiple key index since we need both
    #add_foreign_key :microposts, :users
  end
end
