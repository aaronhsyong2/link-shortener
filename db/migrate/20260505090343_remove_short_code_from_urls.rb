class RemoveShortCodeFromUrls < ActiveRecord::Migration[7.2]
  def change
    remove_index :urls, :short_code
    remove_column :urls, :short_code, :string, null: false, limit: 15
  end
end
