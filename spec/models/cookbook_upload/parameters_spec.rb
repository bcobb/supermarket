require 'isolated_spec_helper'
require 'cookbook_upload/parameters'

describe CookbookUpload::Parameters do

  def params(hash)
    CookbookUpload::Parameters.new(hash)
  end

  describe '#category_name' do
    it 'is extracted from the cookbook JSON' do
      params = params(cookbook: '{"category":"Cool"}', tarball: double)

      expect(params.category_name).to eql('Cool')
    end

    it 'is blank if the cookbook JSON is invalid' do
      params = params(cookbook: 'ack!', tarball: double)

      expect(params.category_name).to eql('')
    end
  end

  describe '#metadata' do
    it 'is extracted from the tarball' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      redis_metadata = CookbookUpload::Metadata.new(
        name: 'redis-test',
        version: '0.1.0',
        license: 'All rights reserved',
        description: 'Installs/Configures redis-test',
        maintainer: 'YOUR_COMPANY_NAME'
      )

      expect(params.metadata).to eql(redis_metadata)
    end

    it 'is blank if the tarball parameter is not a file' do
      params = params(cookbook: '{}', tarball: 'tarball!')

      expect(params.metadata).to eql(CookbookUpload::Metadata.new)
    end

    it 'is blank if the tarball parameter is not GZipped' do
      file = Tempfile.open('notgzipped') { |f| f << "metadata" }

      params = params(cookbook: '{}', tarball: file)

      expect(params.metadata).to eql(CookbookUpload::Metadata.new)
    end

    it 'is blank if the tarball parameter has no metadata.json entry'
    it "is blank if the tarball's metadata.json entry is not actually JSON"
  end

  describe '#errors' do
    it 'is empty if the cookbook and tarball are workable' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.errors).to be_empty
    end

    it 'reports if the cookbook is not valid JSON' do
      params = params(cookbook: 'ack!', tarball: '')

      json_error = I18n.t('api.error_messages.cookbook_not_json')

      expect(params.errors.full_messages).to include(json_error)
    end

    it 'reports if the tarball is not a File'
    it 'reports if the tarball is not GZipped'
    it 'reports if the tarball has no metadata.json entry'
    it "reports if the tarball's metadata.json is not actually JSON"
  end
end
