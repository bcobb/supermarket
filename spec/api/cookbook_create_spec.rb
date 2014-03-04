require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  let(:payload) do
    File.read('spec/support/cookbook_fixtures/redis.tar.gz')
  end

  it 'returns a 200' do
    post '/api/v1/cookbooks'

    expect(response.status.to_i).to eql(200)
  end

  it 'returns the URI for the newly created cookbook' do
    post '/api/v1/cookbooks', cookbook: 'redis', tarball: payload

    expect(json_body['uri']).to match(/api\/v1\/cookbooks\/redis/)
  end
end
