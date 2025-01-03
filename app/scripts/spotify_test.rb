require 'rspotify'

RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_ID"])

artists = RSpotify::Artist.search('Arctic Monkeys')

puts artists
