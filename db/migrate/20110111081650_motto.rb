class Motto < ActiveRecord::Migration
  def self.up
    remove_column :settings, :motto
  end

  def self.down
  end
end
