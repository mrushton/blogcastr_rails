class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :user_id, :null => false
      t.integer :subscribed_to, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
