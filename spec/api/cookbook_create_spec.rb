require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  let(:payload) { fixture_file_upload('spec/support/cookbook_fixtures/redis-test.tgz') }
  let!(:category) { create(:category, name: 'Databases') }

  it 'returns a 200' do
    post '/api/v1/cookbooks', cookbook: { category: 'databases' }, tarball: payload
    expect(response.status.to_i).to eql(200)
  end

  it 'returns the URI for the newly created cookbook' do
    post '/api/v1/cookbooks', cookbook: { category: 'databases' }, tarball: payload
    expect(json_body['uri']).to match(%r(api/v1/cookbooks/redis))
  end
end
