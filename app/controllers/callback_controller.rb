class CallbackController < ApplicationController

  def handler
    puts "Handler!"
  end

  def index
    code = params[:code]
    state = params[:state]
    error = params[:error]

    access_token_response = SpotifyAuthorization::RequestAccessToken.new(code).call
    token = access_token_response.fetch("access_token")

    spotify_client = SpotifyClient::SpotifyClient.new(token)

    current_user_profile = spotify_client.get_current_user_profile
    current_user_playlists = spotify_client.get_current_user_playlists

    # puts JSON.parse(current_user_profile)

    puts current_user_playlists
  end

end
