class CreateBlogcastTags < ActiveRecord::Migration
  def self.up
    create_table :blogcast_tags do |t|
      t.integer :tag_id, :null => false
      t.integer :blogcast_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :blogcast_tags
  end
end
