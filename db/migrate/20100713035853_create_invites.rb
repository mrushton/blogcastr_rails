class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.string :token
      t.integer :user_id
      t.integer :remaining
      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
