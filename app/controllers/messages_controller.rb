class MessagesController < ApplicationController
  before_action :set_message, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  
  def index
    @messages = @shop.messages.normal.latest.page(params[:page])
  end

  def new
    @message = @shop.messages.new(goal: 0)
    render :form
  end

  def create
    @message = @shop.messages.new(message_params)
    if @message.save
      @message.shop_push_message
      flash[:success] = '推送成功！'
      redirect_to messages_path
    else
      flash[:danger] = '推送失败！'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @message.update(message_params)
      @message.shop_push_message
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to messages_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    @message.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_message
      @message = @shop.messages.find_by(id: params[:id])
    end

    def message_params
      params.require(:message).permit(:user_id, :shopper_id, :shop_id, :goal, :messageable_id, :messageable_type, :title, :info)
    end
end
