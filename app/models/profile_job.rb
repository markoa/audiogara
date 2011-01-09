class ProfileJob < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user_id

  scope :unprocessed, where("done_at is null")
  scope :processed, where("done_at is not null")

  def done?
    self.done_at.present?
  end

  def process
    user.build_profile
    update_attribute(:done_at, Time.now)
  end

  def self.process_all
    unprocessed.includes(:user).find_each do |job|
      job.process
    end
  end
end
