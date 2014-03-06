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
        category: 'datastore',
        description: 'Redis: a fast, flexible datastore offering an extremely useful set of data structure primitives'
      )
    end

    let!(:redisio) do
      Cookbook.create(
        name: 'redisio',
        maintainer: 'fruit',
        category: 'datastore',
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
end
