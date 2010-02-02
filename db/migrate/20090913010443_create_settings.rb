class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :user_id, :null => false
      t.string :full_name
      t.string :moto
      t.string :location
      t.string :bio
      t.string :web
      t.string :time_zone
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.string :background_file_name
      t.string :background_content_type
      t.integer :background_file_size
      t.datetime :background_updated_at
      t.boolean :mobile_confirmed
      t.string :mobile_confirmation_token, :limit => 5
      t.string :mobile_number
      t.string :carrier
      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
