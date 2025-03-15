require 'faraday'
require 'faraday/follow_redirects'

module SpotifyAuthorization

  class RequestUserAuthorization
    attr_reader :state_code

    BASE_URL = 'https://accounts.spotify.com'
    REDIRECT_URI = 'http://localhost:3000/callback'
    RESPONSE_TYPE = 'code'
    SCOPE = 'user-read-private user-read-email'

    def initialize
      @spotify_client = Faraday.new(
        url: BASE_URL,
        headers: {
          'Content-Type' => 'application/json'
        },
        params: {
          response_type: RESPONSE_TYPE,
          client_id: ENV['SPOTIFY_CLIENT_ID'],
          scope: SCOPE,
          redirect_uri: REDIRECT_URI,
          state: @state_code,
          show_dialog: true
        }
      )
      @state_code = gen_state_code
    end

    def redirect_url
      response = spotify_client.get('/authorize')
      response.headers.fetch('location')
    end

    private

    attr_reader :spotify_client

    def gen_state_code
      # Used to protect against XSRF attacks.
      # For more details: https://datatracker.ietf.org/doc/html/rfc6749#section-10.12
      Random.hex(16)
    end

  end

  class RequestAccessToken
    attr_reader :spotify_client, :code

    BASE_URL = 'https://accounts.spotify.com'
    REDIRECT_URI = 'http://localhost:3000/callback'
    GRANT_TYPE = 'authorization_code'

    def initialize(code)
      @code = code
      @spotify_client = Faraday.new(
        url: BASE_URL,
        headers: {
          'Authorization' => "Basic #{base64_encoded_creds}",
          'Content-Type' => 'application/x-www-form-urlencoded',
        },
        params: {
          code: code,
          grant_type: GRANT_TYPE,
          redirect_uri: REDIRECT_URI,
        }
      )
    end

    def call
      response = spotify_client.post('/api/token')
      JSON.parse(response.body)
    end

    private

    def base64_encoded_creds
      client_id = ENV['SPOTIFY_CLIENT_ID']
      client_secret = ENV['SPOTIFY_CLIENT_SECRET']

      # using strict_encode, as standard encode adds a newline char every 60 chars
      # which is not the case with strict_encode
      Base64.strict_encode64("#{client_id}:#{client_secret}")
    end

  end

  class SpotifyClient
    attr_reader :spotify_client

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
      response = c.get('/v1/me/playlists')

      JSON.pretty_generate(response.body)
    end

  end

end

