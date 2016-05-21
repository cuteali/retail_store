class DetailCategoriesController < ApplicationController
  before_action :set_detail_category, only: [:edit, :update, :destroy, :stick_top]
  before_filter :authenticate_user!
  # after_action :verify_authorized, only: :destroy
  
  def index
    @q = user_detail_categories.ransack(params[:q])
    @detail_categories = @q.result.sorted.page(params[:page])
  end

  def new
    @detail_category = DetailCategory.new(shop_id: @shop.try(:id), sort: DetailCategory.init_sort(@shop))
    render :form
  end

  def create
    @detail_category = DetailCategory.new(category_params)
    if @detail_category.save
      update_keys(@detail_category, params[:detail_category][:key])
      flash[:success] = '新建成功！'
      redirect_to detail_categories_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @detail_category.update(category_params)
      update_keys(@detail_category, params[:detail_category][:key])
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to detail_categories_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    # authorize @detail_category
    @detail_category.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def stick_top
    @detail_category.update(sort: DetailCategory.init_sort(@shop))
    flash[:success] = '置顶成功！'
    redirect_to :back
  end

  private 
    def set_detail_category
      @detail_category = DetailCategory.find_by(id: params[:id], shop_id: @shop.try(:id))
    end

    def category_params
      params.require(:detail_category).permit(:shop_id, :category_id, :sub_category_id, :name, :key, :sort)
    end
end
