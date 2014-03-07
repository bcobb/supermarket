class Api::V1::CookbookUploadsController < Api::V1Controller
  #
  # POST /api/v1/cookbooks
  #
  # TODO: Properly document this.
  #
  # @example
  #   POST /api/v1/cookbooks
  #
  def create
    cookbook_upload = CookbookUpload.new(upload_params)

    if cookbook_upload.valid?
      cookbook_upload.finish! do |cookbook|
        @cookbook = cookbook
      end
    else
      error(
        error: t('api.error_codes.invalid_data'),
        error_messages: cookbook_upload.errors.full_messages
      )
    end
  end

  rescue_from ActiveRecord::RecordNotUnique do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: t('api.error_messages.version_not_unique')
    )
  end

  rescue_from ActiveRecord::RecordNotSaved do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: t('api.error_messages.version_not_unique')
    )
  end

  rescue_from NotAuthorizedError do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: t('api.error_messages.not_your_cookbook')
    )
  end

  rescue_from ActionController::ParameterMissing do |e|
    error(
      error_code: t('api.error_codes.invalid_data'),
      error_messages: t("api.error_messages.missing_#{e.param}")
    )
  end

  private

  def error(body)
    render json: body, status: 400
  end

  def upload_params
    {
      cookbook: params.require(:cookbook),
      tarball: params.require(:tarball)
    }
  end
end
