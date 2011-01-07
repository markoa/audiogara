module CookieHandler
  def save_name_in_cookie(user)
    cookies.permanent[:lastfm_username] = user.lastfm_username
  end

  def clear_name_from_cookie(user)
    cookies.delete(:lastfm_username)
  end

  def get_name_from_cookie
    # In Cucumber scenarios with rack-test, cookie keys are strings.
    # In normal and test/spec env, they are symbols.
    request.cookies[:lastfm_username] || request.cookies["lastfm_username"]
  end
end
