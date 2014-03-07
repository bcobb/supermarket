require 'cookbook_upload/parameters'

class CookbookUpload

  InvalidUpload = Class.new(RuntimeError)

  def initialize(params)
    @params = Parameters.new(params)
  end

  def valid?
    errors.empty?
  end

  def errors
    ActiveModel::Errors.new([]).tap do |e|
      @params.errors.full_messages.each do |message|
        e.add(:base, message)
      end

      if category.nil?
        message = t(
          'api.error_messages.non_existent_category',
          category_name: @params.category_name
        )

        e.add(:base, message)
      end
    end
  end

  def finish!
    if valid?
      result = cookbook.tap do |book|
        book.publish_version!(@params.metadata, @params.tarball)
      end

      yield result if block_given?
    else
      raise InvalidUpload
    end
  end

  private

  def cookbook
    Cookbook.with_name(@params.metadata.name).first_or_initialize.tap do |book|
      book.category = category
    end
  end

  def category
    Category.with_name(@params.category_name).first
  end
end
