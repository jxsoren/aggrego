class CallbackController < ApplicationController

  def handler
    puts "Handler!"
  end

  def index
    code = params[:code]
    state = params[:state]
    error = params[:error]

    access_token_response = SpotifyClient::AccessTokenClient.new(code).call
    token = access_token_response.fetch("access_token")

    response = SpotifyClient::SpotifyClient.new(token).get_current_user_profile

    puts response
  end

end
