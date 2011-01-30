class HiddenRelease < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :artist_name, :album_name, :reason, :user_id

  REASON_OWNED = 1
  REASON_NOT_INTERESTED = 2

  validates_inclusion_of :reason, :in => [REASON_OWNED, REASON_NOT_INTERESTED]

end
