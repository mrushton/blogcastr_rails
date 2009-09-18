class ClearanceCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :type, :null => false
      #MVR - Blogcastr
      t.string :name
      t.string :email
      t.string :encrypted_password, :limit => 128
      t.string :salt, :limit => 128
      t.string :confirmation_token, :limit => 128
      t.string :remember_token, :limit => 128
      t.boolean :email_confirmed, :default => false, :null => false
      #MVR - Facebook
      t.integer :facebook_id
      #MVR - Twitter
      t.integer :twitter_id
      t.string :twitter_access_token 
      t.timestamps :twitter_token_secret
    end
    add_index :users, [:id, :confirmation_token]
    add_index :users, :name
    add_index :users, :email
    add_index :users, :remember_token
    add_index :users, :facebook_id
  end

  def self.down
    drop_table :users
  end
end
