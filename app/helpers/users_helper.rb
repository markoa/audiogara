module UsersHelper

  def user_has_too_few_known_interests?
    @known_interests_count < Interest::USEFULNESS_THRESHOLD
  end

  def user_name
    @user.realname.present? ? @user.realname.split.first : @user.lastfm_username
  end
end
