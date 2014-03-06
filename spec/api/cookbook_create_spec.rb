require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  context 'the tarball and cookbook are provided and valid' do
    let(:payload) { fixture_file_upload('spec/support/cookbook_fixtures/redis-test.tgz', 'application/x-gzip') }
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

  context 'the cookbook is not provided' do
    let(:payload) { fixture_file_upload('spec/support/cookbook_fixtures/redis-test.tgz', 'application/x-gzip') }
    before(:each) { post '/api/v1/cookbooks', tarball: payload }

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns a MISSING_REQUIRED_DATA error code' do
      expect(json_body['error_code']).to eql('MISSING_REQUIRED_DATA')
    end

    it 'returns a corresponding error message' do
      expect(json_body['error_messages']).to eql("Mulipart POST must include a part named 'cookbook'")
    end
  end

  context 'the tarball is not provided' do
    let!(:category) { create(:category, name: 'Databases') }
    before(:each) { post '/api/v1/cookbooks', cookbook: { category: category } }

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns a MISSING_REQUIRED_DATA error code' do
      expect(json_body['error_code']).to eql('MISSING_REQUIRED_DATA')
    end

    it 'returns a corresponding error message' do
      expect(json_body['error_messages']).to eql("Mulipart POST must include a part named 'tarball'")
    end
  end

  context 'an invalid category is provided' do
    let(:payload) { fixture_file_upload('spec/support/cookbook_fixtures/redis-test.tgz', 'application/x-gzip') }
    let!(:category) { create(:category, name: 'Databases') }
    before(:each) { post '/api/v1/cookbooks', cookbook: { category: 'Fake Category' }, tarball: payload }

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns an INVALID_DATA error code' do
      expect(json_body['error_code']).to eql('INVALID_DATA')
    end

    it 'returns a corresponding error message' do
      expect(json_body['error_messages']).to eql("Category 'Fake Category' does not exist")
    end
  end
end
