class ShoppersController < ApplicationController
  before_action :set_shopper, only: [:edit, :update, :destroy, :show]
  before_filter :authenticate_user!
  after_action :verify_authorized

  def index
    @q = Shopper.normal.ransack(params[:q])
    @shoppers = @q.result.latest.page(params[:page])
    authorize Shopper
  end

  def edit
    authorize @shopper
    render :form
  end

  def update
    authorize @shopper
    if @shopper.update(shopper_params)
      update_keys(@shopper, params[:shopper][:key])
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to shoppers_path
    else
      flash[:success] = '修改失败！'
      redirect_to :back
    end
  end

  def show
    @addresses = @shopper.addresses.normal
  end

  def destroy
    authorize @shopper
    @shopper.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_shopper
      @shopper = Shopper.normal.find(params[:id])
    end

    def shopper_params
      params.require(:shopper).permit(:name, :phone)
    end
end
