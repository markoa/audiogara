class CreateProfileJobs < ActiveRecord::Migration
  def self.up
    create_table :profile_jobs do |t|
      t.references :user
      t.datetime :done_at

      t.timestamps
    end
  end

  def self.down
    drop_table :profile_jobs
  end
end
