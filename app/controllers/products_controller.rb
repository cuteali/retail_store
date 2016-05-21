class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :show, :destroy, :delete_image]
  before_filter :authenticate_user!
  after_action :verify_authorized
  
  def index
    @q = Product.normal.ransack(params[:q])
    @products = @q.result.sorted.page(params[:page])
    authorize Product
  end

  def new
    @product = Product.new
    authorize @product
    render :form
  end

  def create
    @product = Product.new(product_params)
    authorize @product
    if @product.save
      update_keys(@product, params[:product][:key])
      Image.image_upload(params[:product][:images], @product.id, 'Product')
      flash[:success] = '新建成功！'
      redirect_to products_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    authorize @product
    render :form
  end

  def update
    authorize @product
    if @product.update(product_params)
      update_keys(@product, params[:product][:key])
      Image.image_upload(params[:product][:images], @product.id, 'Product')
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to products_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def show
    authorize @product
    @images = @product.images.normal.sorted
  end

  def destroy
    authorize @product
    @product.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def upload_images
    @product = Product.find_by(id: params[:product_id])
    authorize @product
    Image.image_upload([params[:file]], @product.id, 'Product')
    flash[:success] = '上传成功！'
    respond_to do |format|
      format.html { redirect_to product_path(@product) }
      format.json { render json: @product }
    end
  end

  def delete_image
    authorize @product
    image = @product.images.find_by(id: params[:image_id])
    image.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_product
      @product = Product.find_by(id: params[:id])
    end

    def product_params
      params.require(:product).permit(:category_id, :sub_category_id, :detail_category_id, :unit_id, :name, :price, :old_price, :desc, :info, :spec, :sort)
    end
end
