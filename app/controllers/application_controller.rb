require "jwt"

class ApplicationController < ActionController::API
  include Secured
end
