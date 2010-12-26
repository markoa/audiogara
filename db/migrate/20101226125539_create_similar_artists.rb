class CreateSimilarArtists < ActiveRecord::Migration
  def self.up
    create_table :similar_artists do |t|
      t.string :name
      t.string :mbid
      t.float :score
      t.references :artist
      t.integer :parent_artist_id

      t.timestamps
    end
  end

  def self.down
    drop_table :similar_artists
  end
end
