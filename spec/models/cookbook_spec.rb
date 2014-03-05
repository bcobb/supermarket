require 'spec_helper'

describe Cookbook do
  context 'associations' do
    it { should have_many(:cookbook_versions) }
    it { should belong_to(:category) }
  end

  describe '#to_param' do
    it "returns the cookbook's name downcased and parameterized" do
      cookbook = Cookbook.new(name: 'Spicy Curry')
      expect(cookbook.to_param).to eql('spicy-curry')
    end
  end

  describe '#get_version!' do
    let!(:kiwi) { Cookbook.create(name: 'kiwi', maintainer: 'fruit') }
    let!(:kiwi_0_1_0) do
      kiwi.cookbook_versions.create(
        cookbook: kiwi,
        version: '0.1.0',
        description: 'bird',
        license: 'MIT'
      )
    end

    let!(:kiwi_0_2_0) do
      kiwi.cookbook_versions.create(
        cookbook: kiwi,
        version: '0.2.0',
        description: 'better bird',
        license: 'MIT'
      )
    end

    it 'returns the cookbook version specified' do
      expect(kiwi.get_version!('0_1_0')).to eql(kiwi_0_1_0)
    end

    it "returns the highest version when the version is 'latest'" do
      expect(kiwi.get_version!('latest')).to eql(kiwi_0_2_0)
    end

    it 'raises ActiveRecord::RecordNotFound if the version does not exist' do
      expect { kiwi.get_version!('0_4_0') }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.search' do
    let!(:redis) do
      Cookbook.create(
        name: 'redis',
        maintainer: 'tokein',
        category: create(:category, name: 'datastore'),
        description: 'Redis: a fast, flexible datastore offering an extremely useful set of data structure primitives'
      )
    end

    let!(:redisio) do
      Cookbook.create(
        name: 'redisio',
        maintainer: 'fruit',
        category: create(:category, name: 'datastore'),
        description: 'Installs/Configures redis'
      )
    end

    it 'returns cookbooks with a similar name' do
      expect(Cookbook.search('redis')).to include(redis)
      expect(Cookbook.search('redis')).to include(redisio)
    end

    it 'returns cookbooks with a similar maintainer' do
      expect(Cookbook.search('fruit')).to include(redisio)
      expect(Cookbook.search('fruit')).to_not include(redis)
      expect(Cookbook.search('tokein')).to include(redis)
      expect(Cookbook.search('tokein')).to_not include(redisio)
    end

    it 'returns cookbooks with a similar category' do
      expect(Cookbook.search('datastore')).to include(redisio)
      expect(Cookbook.search('datastore')).to include(redis)
    end

    it 'returns cookbooks with a similar description' do
      expect(Cookbook.search('fast')).to include(redis)
      expect(Cookbook.search('fast')).to_not include(redisio)
    end
  end

  describe '.share!' do
    let(:category) { create(:category, name: 'Databases') }
    let(:tarball) { File.open('spec/support/cookbook_fixtures/redis-test.tgz') }

    context 'for a new cookbook' do
      let(:cookbook) { Cookbook.share!(category, tarball) }
      let(:cookbook_version) { cookbook.get_version!('latest') }

      it 'creates a cookbook with metadata abstracted from a tarball' do
        expect(cookbook.name).to eql('redis-test')
        expect(cookbook.description).to eql('Installs/Configures redis-test')
        expect(cookbook.maintainer).to eql('YOUR_COMPANY_NAME')
      end

      it 'creates a cookbook version with metadata abstracted from a tarball' do
        expect(cookbook_version.license).to eql('All rights reserved')
        expect(cookbook_version.version).to eql('0.1.0')
        expect(cookbook_version.description).to eql('Installs/Configures redis-test')
      end

      it 'associates the cookbook with a specified category' do
        expect(cookbook.category).to eql(category)
      end

      it 'saves the tarball on the cookbook version' do
        expect(File.open(cookbook_version.tarball.path).read).to eql(tarball.read)
      end
    end
  end
end
