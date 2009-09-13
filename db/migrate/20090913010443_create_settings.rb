class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :user_id, :null => false
      t.string :name
      t.string :about
      t.string :web
      #MVR - need to set timezone
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.string :background_file_name
      t.string :background_content_type
      t.integer :background_file_size
      t.datetime :background_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
