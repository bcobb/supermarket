require 'active_model/errors'
require 'cookbook_upload/metadata'
require 'json'
require 'rubygems/package'

class CookbookUpload
  class Parameters
    attr_reader :tarball

    MissingMetadata = Class.new(RuntimeError)
    TarballNotIO = Class.new(RuntimeError)

    def initialize(params)
      @cookbook_data = params.fetch(:cookbook)
      @tarball = params.fetch(:tarball)
    end

    def category_name
      cookbook = maybe_cookbook

      if cookbook.is_a?(ActiveModel::Errors)
        cookbook = {}
      end

      cookbook.fetch('category', '').to_s
    end

    def metadata
      if maybe_metadata.is_a?(ActiveModel::Errors)
        Metadata.new
      else
        maybe_metadata
      end
    end

    def valid?
      errors.empty?
    end

    def errors
      ActiveModel::Errors.new([]).tap do |errors|
        [maybe_metadata, maybe_cookbook].each do |maybe|
          if maybe.is_a?(ActiveModel::Errors)
            maybe.full_messages.each { |message| errors.add(:base, message) }
          end
        end
      end
    end

    private

    def maybe_metadata
      parsing_errors = ActiveModel::Errors.new([])

      begin
        raise TarballNotIO unless tarball.is_a?(IO)

        Zlib::GzipReader.open(tarball.path) do |gzip|
          metadata = nil

          Gem::Package::TarReader.new(gzip) do |tar|
            entry = tar.find { |e| e.header.name =~ /metadata.json/ }

            if entry
              metadata = Metadata.new(JSON.parse(entry.read))
            else
              raise MissingMetadata
            end
          end

          metadata
        end
      rescue JSON::ParserError
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.metadata_not_json'))
        end
      rescue MissingMetadata
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.missing_metadata'))
        end
      rescue Zlib::GzipFile::Error
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.tarball_not_gzipped'))
        end
      rescue TarballNotIO
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.tarball_not_io'))
        end
      end
    end

    def maybe_cookbook
      parsing_errors = ActiveModel::Errors.new([])

      begin
        JSON.parse(@cookbook_data)
      rescue JSON::ParserError
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.cookbook_not_json'))
        end
      end
    end
  end
end
