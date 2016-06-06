# encoding: utf-8
class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :qiniu

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def convert_to_nice_date
    model.created_at.strftime("%Y/%m/%d")
  end

  def extension_white_list
     %w(jpg jpeg gif png)
  end

  def filename
     @name ||= "#{timestamp}.#{file.extension}" if original_filename.present? and super.present?
  end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.to_i)
  end

  def delete
    nil
  end

end
