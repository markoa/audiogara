class CreateInterests < ActiveRecord::Migration
  def self.up
    create_table :interests do |t|
      t.references :user
      t.references :artist
      t.float :score
      t.string :artist_name
      t.datetime :artist_processed_at

      t.timestamps
    end

    add_index :interests, :user_id
  end

  def self.down
    drop_table :interests
  end
end
