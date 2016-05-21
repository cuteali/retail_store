class SubCategoriesController < ApplicationController
  before_action :set_sub_category, only: [:edit, :update, :destroy, :stick_top]
  before_filter :authenticate_user!
  # after_action :verify_authorized, only: :destroy
  
  def index
    @q = user_sub_categories.ransack(params[:q])
    @sub_categories = @q.result.sorted.page(params[:page])
  end

  def new
    @sub_category = SubCategory.new(shop_id: @shop.try(:id), sort: SubCategory.init_sort(@shop))
    render :form
  end

  def create
    @sub_category = SubCategory.new(category_params)
    if @sub_category.save
      flash[:success] = '新建成功！'
      redirect_to sub_categories_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @sub_category.update(category_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to sub_categories_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    # authorize @sub_category
    @sub_category.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def stick_top
    @sub_category.update(sort: SubCategory.init_sort(@shop))
    flash[:success] = '置顶成功！'
    redirect_to :back
  end

  private 
    def set_sub_category
      @sub_category = SubCategory.find_by(id: params[:id], shop_id: @shop.try(:id))
    end

    def category_params
      params.require(:sub_category).permit(:shop_id, :category_id, :name, :sort)
    end
end
