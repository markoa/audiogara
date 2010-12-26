class AddArtistIdToTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :artist_id, :integer
  end

  def self.down
    remove_column :torrents, :artist_id
  end
end
