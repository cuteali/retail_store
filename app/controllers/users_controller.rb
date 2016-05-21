class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  after_action :verify_authorized

  def index
    @users = User.normal.page(params[:page])
    authorize User
  end

  def edit
    authorize @user
    render :form
  end

  def update
    authorize @user
    if @user.update(user_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to users_path
    end
  end

  def destroy
    authorize @user
    @user.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_user
      @user = User.normal.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:shop_id, :role, :username, :phone, :email)
    end
end