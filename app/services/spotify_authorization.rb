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

end
