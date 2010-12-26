class AddArtistProcessedAtToTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :artist_processed_at, :datetime
  end

  def self.down
    remove_column :torrents, :artist_processed_at
  end
end
