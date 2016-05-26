class AdvertsController < ApplicationController
  before_action :set_advert, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  
  def index
    @q = @shop.adverts.normal.ransack(params[:q])
    @adverts = @q.result.sorted.page(params[:page])
  end

  def new
    @advert = Advert.new(shop_id: @shop.try(:id))
    render :form
  end

  def create
    @advert = Advert.new(advert_params)
    if @advert.save
      update_keys(@advert, params[:advert][:key])
      flash[:success] = '新建成功！'
      redirect_to adverts_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @advert.update(advert_params)
      update_keys(@advert, params[:advert][:key])
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to adverts_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    @advert.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_advert
      @advert = Advert.find_by(id: params[:id], shop_id: @shop.try(:id))
    end

    def advert_params
      params.require(:advert).permit(:shop_id, :shop_product_id)
    end
end
