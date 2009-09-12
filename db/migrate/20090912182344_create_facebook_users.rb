class CreateFacebookUsers < ActiveRecord::Migration
  def self.up
    create_table :facebook_users do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_users
  end
end
