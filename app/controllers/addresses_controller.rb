class AddressesController < ApplicationController
  before_action :set_address, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  after_action :verify_authorized

  def edit
    authorize @address
    render :form
  end

  def update
    authorize @address
    if @address.update(address_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to shopper_path(@shopper)
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    authorize @address
    @address.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_address
      @shopper = Shopper.find_by(id: params[:shopper_id])
      @address = @shopper.addresses.normal.find_by(id: params[:id])
    end

    def address_params
      params.require(:address).permit(:area, :detail, :lat, :lng, :receive_name, :receive_phone, :is_default)
    end
end
