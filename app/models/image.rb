class Image < ActiveRecord::Base
  mount_uploader :key, AvatarUploader

  belongs_to :menuable, polymorphic: true

  enum status: [ :normal, :deleted ]

  def self.image_upload(image_params, imageable_id, imageable_type)
    image_params.each do |img|
      Image.create(key: img, imageable_id: imageable_id, imageable_type: imageable_type)
    end
  end

  def self.uptoken
    put_policy = Qiniu::Auth::PutPolicy.new(
      "retail-store",
      nil,
      1800
    )

    uptoken = Qiniu::Auth.generate_uptoken(put_policy)
  end
end
