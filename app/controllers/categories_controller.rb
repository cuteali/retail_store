class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy, :stick_top]
  before_filter :authenticate_user!
  # after_action :verify_authorized, only: :destroy
  
  def index
    @categories = user_categories.page(params[:page])
    respond_to do |format|
      format.html
      format.xls {
        send_data(ExportXls.export_excel,
        :type => "text/excel;charset=utf-8; header=present",
        :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
      }
    end
  end

  def new
    @category = Category.new(shop_id: @shop.try(:id), sort: Category.init_sort(@shop))
    render :form
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      update_keys(@category, params[:category][:key], params[:category][:logo_key])
      flash[:success] = '新建成功！'
      redirect_to categories_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @category.update(category_params)
      update_keys(@category, params[:category][:key], params[:category][:logo_key])
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to categories_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    # authorize @category
    @category.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def stick_top
    @category.update(sort: Category.init_sort(@shop))
    flash[:success] = '置顶成功！'
    redirect_to :back
  end

  def select_options
    if params[:category_id]
      options = Object.const_get(params[:class_name]).where(shop_id: @shop.try(:id), category_id: params[:category_id]).normal.order(:id)
    elsif params[:sub_category_id]
      options = Object.const_get(params[:class_name]).where(shop_id: @shop.try(:id), sub_category_id: params[:sub_category_id]).normal.order(:id)
    elsif params[:detail_category_id]
      options = Object.const_get(params[:class_name]).where(shop_id: @shop.try(:id), detail_category_id: params[:detail_category_id]).normal.sorted
    end
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end

  private 
    def set_category
      @category = Category.find_by(id: params[:id], shop_id: @shop.try(:id))
    end

    def category_params
      params.require(:category).permit(:shop_id, :name, :name_as, :is_app_index, :sort)
    end
end
