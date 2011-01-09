module LoginHandler
  
  protected

  def get_name_from_cookie
    # In Cucumber scenarios with rack-test, cookie keys are strings.
    # In normal and test/spec env, they are symbols.
    request.cookies[:lastfm_username] || request.cookies["lastfm_username"]
  end

  def current_user
    @current_user ||= User.find_by_lastfm_username(get_name_from_cookie)
  end

  def current_user=(user)
    cookies.permanent[:lastfm_username] = user.lastfm_username
    @current_user = user
  end

  def logged_in?
    !!current_user
  end

  def log_out(user)
    cookies.delete(:lastfm_username)
  end

  # include hook
  #
  def self.included(c)
    return unless c < ActionController::Base
    c.helper_method :current_user, :logged_in?
  end
end
