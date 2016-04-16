#!/usr/bin/env ruby

require 'qiniu'

Qiniu.establish_connection! :access_key => 'WdY_W0-ZktWrx1wWG5DFQTbNTd8HNh4yY7uPYBbA',
                            :secret_key => 'PeB-BFYl7EK4InIUHtAYfJzlMbHy-Lh1MWubc2Yz'

Rails.application.config.qiniu_domain = "7xszen.com1.z0.glb.clouddn.com"