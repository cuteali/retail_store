class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy, :forget_password, :reset_password]
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
    else
      flash[:success] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    authorize @user
    @user.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def forget_password
    authorize @user
  end

  def reset_password
    authorize @user
    @user.password = params[:password]
    @user.password_confirmation = params[:password]
    if @user.save
      flash[:success] = '重置密码成功！'
      redirect_to users_path
    else
      flash[:danger] = '重置密码失败！'
      redirect_to :back
    end
  end

  private 
    def set_user
      @user = User.normal.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:shop_id, :role, :username, :phone, :email)
    end
end