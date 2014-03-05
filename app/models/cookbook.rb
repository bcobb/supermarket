require 'rubygems/package'
require 'zlib'

class Cookbook < ActiveRecord::Base
  include PgSearch

  pg_search_scope(
    :search,
    against: {
      name: 'A',
      description: 'B',
      maintainer: 'D'
    },
    associated_against: {
      category: :name
    },
    using: {
      tsearch: { prefix: true, dictionary: 'english' }
    }
  )

  # Associations
  # --------------------
  has_many :cookbook_versions, -> { order(created_at: :desc) }
  belongs_to :category

  #
  # Returns the name of the +Cookbook+ parameterized.
  #
  # @return [String] the name of the +Cookbook+ parameterized
  #
  def to_param
    name.parameterize
  end

  #
  # Return the specified +CookbookVersion+. Raises an
  # +ActiveRecord::RecordNotFound+ if the version does not exist. The first line
  # of the method translates the version from a parameter friendly verison
  # (2_0_1) to a dot version (2.0.1).
  #
  # @example
  #   cookbook.get_version!("1_0_0")
  #   cookbook.get_version!("latest")
  #
  # @param version [String] the version of the Cookbook to find. Pass in
  #                         'latest' to return the latest version of the
  #                         cookbook.
  #
  # @return [CookbookVersion] the +CookbookVersion+ with the version specified
  #
  def get_version!(version)
    version.gsub!(/_/, '.')

    if version == 'latest'
      cookbook_versions.first!
    else
      cookbook_versions.find_by!(version: version)
    end
  end

  #
  # TODO: Document
  #
  def self.share!(category, tarball)
    metadata = extract_metadata_from(tarball)
    cookbook = category.cookbooks.create(
      name: metadata['name'],
      maintainer: metadata['maintainer'],
      description: metadata['description']
    )

    cookbook.cookbook_versions.create!(
      license: metadata['license'],
      version: metadata['version'],
      description: metadata['description']
    )

    cookbook
  end

  private

  def self.extract_metadata_from(tarball)
    contents = nil

    Gem::Package::TarReader.new(Zlib::GzipReader.open tarball.path) do |tar|
      entry = tar.find { |e| e.header.name =~ /metadata.json/ }
      contents = JSON.parse(entry.read)
    end

    contents
  end
end
