class CreateBlogcasts < ActiveRecord::Migration
  def self.up
    create_table :blogcasts do |t|
      t.integer :user_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :blogcasts
  end
end
