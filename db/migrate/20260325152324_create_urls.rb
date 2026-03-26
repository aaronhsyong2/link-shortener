class CreateUrls < ActiveRecord::Migration[7.2]
  def change
    create_table :urls do |t|
      t.string :target_url, null: false
      t.string :short_code, null: false, limit: 15
      t.string :title
      t.integer :clicks_count, default: 0, null: false

      t.timestamps
    end
    add_index :urls, :short_code, unique: true
  end
end
