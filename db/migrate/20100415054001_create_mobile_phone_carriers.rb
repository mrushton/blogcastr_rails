class CreateMobilePhoneCarriers < ActiveRecord::Migration
  def self.up
    create_table :mobile_phone_carriers do |t|
      t.string :name, :null => false
      t.string :sms_email_host, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :mobile_phone_carriers
  end
end
