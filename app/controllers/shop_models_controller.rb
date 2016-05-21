class ShopModelsController < ApplicationController
  before_action :set_shop_model, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  after_action :verify_authorized
  
  def index
    @shop_models = ShopModel.normal.page(params[:page])
    authorize ShopModel
  end

  def new
    @shop_model = ShopModel.new
    authorize @shop_model
    render :form
  end

  def create
    @shop_model = ShopModel.new(shop_model_params)
    authorize @shop_model
    if @shop_model.save
      flash[:success] = '新建成功！'
      redirect_to shop_models_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    authorize @shop_model
    render :form
  end

  def update
    authorize @shop_model
    if @shop_model.update(shop_model_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to shop_models_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    authorize @shop_model
    @shop_model.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_shop_model
      @shop_model = ShopModel.find_by(id: params[:id])
    end

    def shop_model_params
      params.require(:shop_model).permit(:name)
    end
end
