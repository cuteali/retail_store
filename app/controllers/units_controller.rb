class UnitsController < ApplicationController
  before_action :set_unit, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  after_action :verify_authorized
  
  def index
    @units = Unit.normal.page(params[:page])
    authorize Unit
  end

  def new
    @unit = Unit.new
    authorize @unit
    render :form
  end

  def create
    @unit = Unit.new(unit_params)
    authorize @unit
    if @unit.save
      flash[:success] = '新建成功！'
      redirect_to units_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    authorize @unit
    render :form
  end

  def update
    authorize @unit
    if @unit.update(unit_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to units_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    authorize @unit
    @unit.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_unit
      @unit = Unit.find_by(id: params[:id])
    end

    def unit_params
      params.require(:unit).permit(:name)
    end
end
