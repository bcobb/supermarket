require 'spec_helper'

describe CookbookUpload do
  describe '#finish!' do
    it 'creates a new cookbook if the given name is original' do
      create(:category, name: 'Other')

      cookbook = JSON.dump({ 'category' => 'Other' })
      tarball = File.open('spec/support/cookbook_fixtures/redis-test.tgz')

      upload = CookbookUpload.new(cookbook: cookbook, tarball: tarball)

      expect do
        upload.finish!
      end.to change(Cookbook, :count).by(1)
    end

    it 'updates the existing cookbook if the given name is a duplicate' do
      create(:category, name: 'Other')

      cookbook = JSON.dump({ 'category' => 'Other' })

      tarball_one = File.open('spec/support/cookbook_fixtures/redis-test.tgz')
      tarball_two = File.open('spec/support/cookbook_fixtures/redis-test-2.tgz')

      CookbookUpload.new(cookbook: cookbook, tarball: tarball_one).finish!

      update = CookbookUpload.new(cookbook: cookbook, tarball: tarball_two)

      expect do
        update.finish!
      end.to_not change(Cookbook, :count)
    end
  end
end
