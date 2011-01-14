module UsersHelper

  def user_has_too_few_known_interests?
    @known_interests_count < Interest::USEFULNESS_THRESHOLD
  end
end
