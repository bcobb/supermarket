class CookbookVersion < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :cookbook

  # Attachments
  # --------------------
  has_attached_file :tarball

  # Validations
  # --------------------
  validates :license, presence: true
  validates :version, presence: true
  validates :description, presence: true
  validates :cookbook_id, presence: true
  validates_attachment :tarball, content_type: { content_type: ['application/x-gzip'] }

  #
  # Returns the verison of the +CookbookVersion+ with underscores replacing the
  # dots.
  #
  # @example
  #   cookbook_version = CookbookVersion.new(version: '1.0.2')
  #   cookbook_version.to_param # => '1_0_2'
  #
  # @return [String] the version of the +CookbookVersion+
  #
  def to_param
    version.gsub(/\./, '_')
  end
end
