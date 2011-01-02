class RemoveArtistProcessedAtFromInterests < ActiveRecord::Migration
  def self.up
    remove_column :interests, :artist_processed_at
  end

  def self.down
    add_column :interests, :artist_processed_at, :datetime
  end
end
