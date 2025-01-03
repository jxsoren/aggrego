class LoginController < ApplicationController

  def index
    client = SpotifyClient::UserAuthorization.new.call

    @url = client

    redirect_to @url, allow_other_host: true
  end

end
