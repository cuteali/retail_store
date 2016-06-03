class ShopsController < ApplicationController
  before_action :set_shop, only: [:edit, :update, :destroy, :init_categories_products]
  before_filter :authenticate_user!
  after_action :verify_authorized
  
  def index
    @shops = Shop.normal.latest.page(params[:page])
    authorize Shop
  end

  def new
    @shop = Shop.new
    authorize @shop
    render :form
  end

  def create
    @shop = Shop.new(shop_params)
    authorize @shop
    if @shop.save
      flash[:success] = '新建成功！'
      redirect_to shops_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    authorize @shop
    render :form
  end

  def update
    authorize @shop
    if @shop.update(shop_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to shops_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    authorize @shop
    @shop.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def init_categories_products
    authorize @shop
    Category.init_shop_categories(@shop)
    # Product.init_shop_products(@shop)
    flash[:success] = '店铺初始化分类、产品成功！'
    render js: "location.reload();"
  end

  private 
    def set_shop
      @shop = Shop.normal.find_by(id: params[:id])
    end

    def shop_params
      params.require(:shop).permit(:shop_model_id, :name, :address, :lat, :lng, :tel, :phone, :director, :delivery_range, :start_at, :end_at, :send_price, :freight)
    end
end
