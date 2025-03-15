require 'faraday'

class SpotifyClient
  BASE_URL = 'https://api.spotify.com'

  def initialize(access_token)
    @access_token = access_token
    @spotify_client = Faraday.new(
      url: BASE_URL,
      headers: {
        'Authorization' => "Bearer #{@access_token}",
        'Content-Type' => 'application/json',
      }
    )
  end

  def get_current_user_profile
    response = spotify_client.get('/v1/me')
    JSON.pretty_generate(response.body)
  end

  def get_current_user_playlists
    response = spotify_client.get('/v1/me/playlists')
    JSON.pretty_generate(response.body)
  end

  private

  attr_reader :spotify_client

end