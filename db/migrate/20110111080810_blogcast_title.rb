class BlogcastTitle < ActiveRecord::Migration
  def self.up
    change_column :blogcasts, :title, :string, :limit => 30
  end

  def self.down
  end
end
