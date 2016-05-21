class HomeController < ApplicationController
  skip_before_filter :filter_current_user

  def index
    if current_user && current_user.admin?
      Rails.logger.info "1111111111"
      redirect_to users_path
    elsif request.referrer =~ /users/i || current_user.blank?
      Rails.logger.info "2222222222"
      redirect_to new_user_session_path
    end
  end

  def upload_xls
    uploaded_file = params[:file]
    return redirect_to :back, alert: "请导入格式为.xls的文件。" if uploaded_file.blank?

    tempfile = uploaded_file.tempfile
    return redirect_to :back, alert: "请导入格式为.xls的文件。" if uploaded_file.original_filename !~ /\.xls\z/i
    return redirect_to :back, alert: "上传文件不能大于1M，请重新上传。" if tempfile.size > 1024 ** 2

    file = copy_tempfile(tempfile)
    result = ImportXls.import(file)
    FileUtils.rm file

    respond_to do |format|
      if result.is_a?(Hash) # 产品导入失败，数据格式不正确
        format.json { render json: result }
        format.html { redirect_to :back, alert: result[:message] }
      else
        format.json { flash.success = "文件上传成功，请于10分钟后查看数据导入情况"; render json: {} }
        format.html { redirect_to :back, success: "文件上传成功，请于10分钟后查看数据导入情况"  }
      end
    end
  end

  private
    def copy_tempfile(tempfile)
      dir = "#{Rails.root}/public/uploads/tmp/category_xls"
      file = "#{dir}/#{Time.now.to_s(:number)}.xls"
      FileUtils.mkdir_p dir
      FileUtils.copy tempfile.path, file
      file
    end
end
