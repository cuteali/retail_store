::CarrierWave.configure do |config|
  config.storage              = :qiniu
  config.qiniu_access_key     = "WdY_W0-ZktWrx1wWG5DFQTbNTd8HNh4yY7uPYBbA"
  config.qiniu_secret_key     = 'PeB-BFYl7EK4InIUHtAYfJzlMbHy-Lh1MWubc2Yz'
  config.qiniu_bucket         = "retail-store"
  config.qiniu_bucket_domain  = "7xszen.com1.z0.glb.clouddn.com"
  config.qiniu_bucket_private = false #default is false
  config.qiniu_block_size     = 4*1024*1024
  config.qiniu_protocol       = "http"
  config.qiniu_can_overwrite  = true
end