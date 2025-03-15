class LoginController < ApplicationController

  def index
    client = SpotifyAuthorization::RequestUserAuthorization.new
    redirect_to client.redirect_url, allow_other_host: true
  end

end
