class Api::UploadsController < ApplicationController
  require "aws-sdk-s3"
  before_action :authorize

  def generate_presigned_url
    player_id = @decoded_token.token[0]["sub"]
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV["AWS_BUCKET_NAME"])
    object_key = "profile_pictures/#{player_id}/#{player_id}_#{SecureRandom.uuid}_#{params[:file_name]}"
    presigned_url = bucket.object(object_key).presigned_url(:put, expires_in: 360, content_type: params[:content_type])
    render json: { url: presigned_url, key: object_key }
  rescue StandardError => e
    render json: { message: e.message }, status: :internal_server_error
  end
end
