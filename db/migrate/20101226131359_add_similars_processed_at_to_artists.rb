class AddSimilarsProcessedAtToArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :similars_processed_at, :datetime
  end

  def self.down
    remove_column :artists, :similars_processed_at
  end
end
