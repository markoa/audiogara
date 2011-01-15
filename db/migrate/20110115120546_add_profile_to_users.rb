class AddProfileToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lastfm_id, :integer
    add_column :users, :name, :string
    add_column :users, :realname, :string
    add_column :users, :url, :string
    add_column :users, :image_small, :string
    add_column :users, :image_medium, :string
    add_column :users, :image_large, :string
    add_column :users, :image_extralarge, :string
    add_column :users, :country, :string
    add_column :users, :age, :integer
    add_column :users, :gender, :string, :limit => 1
    add_column :users, :playcount, :integer
    add_column :users, :registered, :date
  end

  def self.down
    remove_column :users, :lastfm_id
    remove_column :users, :name
    remove_column :users, :realname
    remove_column :users, :url
    remove_column :users, :image_small
    remove_column :users, :image_medium
    remove_column :users, :image_large
    remove_column :users, :image_extralarge
    remove_column :users, :country
    remove_column :users, :age
    remove_column :users, :gender
    remove_column :users, :playcount
    remove_column :users, :registered
  end
end
