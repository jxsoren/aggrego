require 'faraday'
require 'faraday/follow_redirects'

module SpotifyClient

  class UserAuthorization
    attr_reader :http_client

    BASE_URL = 'https://accounts.spotify.com'
    REDIRECT_URI = 'http://localhost:3000/callback'
    RESPONSE_TYPE = 'code'
    SCOPE = 'user-read-private user-read-email'

    def initialize
      @http_client = Faraday.new(
        url: BASE_URL,
        headers: {
          'Content-Type' => 'application/json'
        },
        params: {
          response_type: RESPONSE_TYPE,
          client_id: ENV['SPOTIFY_CLIENT_ID'],
          scope: SCOPE,
          redirect_uri: REDIRECT_URI,
          state: gen_state_code,
          show_dialog: true
        }
      )
    end

    def call
      # Request User Authorization
      auth_response = http_client.get('/authorize')
      auth_response.headers.fetch('location')
    end

    private

    def gen_state_code
      # Used to protect against XSRF attacks.
      # For more details: https://datatracker.ietf.org/doc/html/rfc6749#section-10.12
      Random.hex(16)
    end

  end

  test = UserAuthorization.new.call

  puts test

  class AccessTokenClient
    attr_reader :http_client, :code

    BASE_URL = 'https://accounts.spotify.com'
    REDIRECT_URI = 'http://localhost:3000/callback'
    GRANT_TYPE = 'authorization_code'

    def initialize(code)
      @code = code

      @http_client = Faraday.new(
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
      response = http_client.post('/api/token')

      response_body = JSON.parse(response.body)

      puts response_body

      response_body
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
    attr_reader :http_client

    BASE_URL = 'https://api.spotify.com'

    def initialize(access_token)
      @access_token = access_token

      @http_client = Faraday.new(
        url: BASE_URL,
        headers: {
          'Authorization' => "Bearer #{@access_token}",
          'Content-Type' => 'application/json',
        }
      )
    end

    def get_current_user_profile
      http_client.get('/v1/me')
    end

  end

end

