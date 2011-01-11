class BlogcastTitle < ActiveRecord::Migration
  def self.up
    change_column :blogcasts, :title, :string, :limit => 35
  end

  def self.down
  end
end
