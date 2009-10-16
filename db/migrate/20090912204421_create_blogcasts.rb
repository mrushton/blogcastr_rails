class CreateBlogcasts < ActiveRecord::Migration
  def self.up
    create_table :blogcasts do |t|
      t.integer :user_id, :null => false
      t.string :title, :null => false
      #TODO: find a way to search through the tags
      t.string :tags
      t.string :description
      t.integer :year, :null => false
      t.integer :day, :null => false
      t.integer :month, :null => false
      t.string :link_title, :null => false
      t.datetime :starting_at, :null => false
      #MVR - keep track of view via counter cache
      #TODO: add more where appropriate
      t.integer :views_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :blogcasts
  end
end