class AddTitleFetchedAtToUrls < ActiveRecord::Migration[7.2]
  def change
    add_column :urls, :title_fetched_at, :datetime
  end
end
