class TwitterUsername < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_username, :string, :limit => 20 
  end

  def self.down
    remove_column :users, :twitter_username
  end
end
