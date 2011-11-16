class PostShortUrl < ActiveRecord::Migration
  def self.up
    add_column :posts, :short_url, :string
  end

  def self.down
    remove_column :posts, :short_url
  end
end
