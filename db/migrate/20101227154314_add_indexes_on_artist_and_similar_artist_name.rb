class AddIndexesOnArtistAndSimilarArtistName < ActiveRecord::Migration
  def self.up
    add_index :artists, :name
    add_index :similar_artists, :name
  end

  def self.down
    remove_index :artists, :name
    remove_index :similar_artists, :name
  end
end
