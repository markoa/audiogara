class ApplicationController < ActionController::Base

  include LoginHandler

  protect_from_forgery
end
