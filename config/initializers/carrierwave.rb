require 'carrierwave/orm/activerecord'
CarrierWave.configure do |config|
  # config.cache_dir = "#{Rails.root}/tmp/uploads"
  # config.fog_credentials = {
  #   :provider => 'AWS',
  #   :aws_access_key_id => ENV['AWS_KEY'],
  #   :aws_secret_access_key => ENV['AWS_SECRET_KEY'],
  #   :region => 'ap-southeast-1'
  # }
  # config.fog_directory  = ENV['S3_BUCKET_NAME']
end 