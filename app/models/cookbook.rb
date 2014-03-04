class Cookbook < ActiveRecord::Base
  include PgSearch

  pg_search_scope(
    :search,
    against: {
      name: 'A',
      description: 'B',
      category: 'C',
      maintainer: 'D'
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
    cookbook = Cookbook.create(name: 'redis', maintainer: 'john@example.com')
    cookbook.cookbook_versions.create!(license: 'MIT', version: '0.1.0', description: 'Configure and install redis.')
    cookbook
  end
end
