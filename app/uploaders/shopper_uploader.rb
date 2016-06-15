# encoding: utf-8
class ShopperUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :qiniu

  def store_dir
    nil
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{secure_token(10)}.#{file.extension}" if original_filename.present?
  end

  def secure_token(length = 16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
end
