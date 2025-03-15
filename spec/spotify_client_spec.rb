# frozen_string_literal: true

require 'spec_helper'
require './app/services/spotify_authorization'

describe SpotifyAuthorization::RequestUserAuthorization do
  describe '#redirect_url' do
    subject { described_class.new }

    let(:response) do

    end

    context 'when state code does not match' do

      it 'raises exception' do
        expect { subject.authorize_request }.to raise_error
      end

    end

  end
end