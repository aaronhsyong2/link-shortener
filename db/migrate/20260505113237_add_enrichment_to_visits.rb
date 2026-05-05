class AddEnrichmentToVisits < ActiveRecord::Migration[7.2]
  def change
    change_table :visits, bulk: true do |t|
      t.string :user_agent, limit: 512
      t.string :referer, limit: 2048
      t.string :referer_domain, limit: 256
      t.string :browser, limit: 128
      t.string :os, limit: 128
      t.string :device_type, limit: 32
      t.boolean :is_bot, default: false
    end

    add_index :visits, :browser
    add_index :visits, :os
    add_index :visits, :device_type
    add_index :visits, :referer_domain
    add_index :visits, :is_bot
  end
end
