class CreateBlogcastrUsers < ActiveRecord::Migration
  def self.up
    create_table :blogcastr_users do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :blogcastr_users
  end
end
