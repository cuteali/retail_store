class ShopProductsController < ApplicationController
  before_action :set_shop_product, only: [:edit, :update, :show, :destroy, :delete_image, :stick_top]
  before_filter :authenticate_user!
  
  def index
    @q = @shop.shop_products.normal.ransack(params[:q])
    @shop_products = @q.result.sorted.page(params[:page])
  end

  def new
    @shop_product = ShopProduct.new(shop_id: @shop.try(:id), sort: ShopProduct.init_sort(@shop))
    render :form
  end

  def create
    @shop_product = ShopProduct.new(shop_product_params)
    if @shop_product.save
      update_keys(@shop_product, params[:shop_product][:key])
      Image.image_upload(params[:shop_product][:images], @shop_product.id, 'ShopProduct')
      flash[:success] = '新建成功！'
      redirect_to shop_products_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @shop_product.update(shop_product_params)
      update_keys(@shop_product, params[:shop_product][:key])
      Image.image_upload(params[:shop_product][:images], @shop_product.id, 'ShopProduct')
      Cart.where(shop_product_id: @shop_product.id).destroy_all if @shop_product.sold_off?
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to shop_products_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def show
    @images = @shop_product.images.normal.sorted
  end

  def destroy
    @shop_product.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def upload_images
    @shop_product = @shop.shop_products.normal.find_by(id: params[:shop_product_id])
    Image.image_upload([params[:file]], @shop_product.id, 'ShopProduct')
    flash[:success] = '上传成功！'
    respond_to do |format|
      format.html { redirect_to shop_product_path(@shop_product) }
      format.json { render json: @shop_product }
    end
  end

  def delete_image
    image = @shop_product.images.find_by(id: params[:image_id])
    image.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def select_product
    product = @shop.shop_products.normal.find_by(id: params[:product_id])
    html = get_select_product_html(product)
    render json: {html: html, product_id: product.id}
  end

  def search_product
    options = @shop.shop_products.normal.where("name like ?", "%#{params[:product_name]}%").sorted
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end

  def stick_top
    @shop_product.update(sort: ShopProduct.init_sort(@shop))
    redirect_to :back, notice: '操作成功'
  end

  private 
    def set_shop_product
      @shop_product = @shop.shop_products.normal.find_by(id: params[:id])
    end

    def shop_product_params
      params.require(:shop_product).permit(:shop_id, :category_id, :sub_category_id, :detail_category_id, :unit_id, :name, :price, :old_price, 
        :desc, :info, :spec, :stock_volume, :sales_volume, :sort, :is_app_index, :state)
    end
end
