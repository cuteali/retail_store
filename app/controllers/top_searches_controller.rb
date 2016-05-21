class TopSearchesController < ApplicationController
  before_action :set_top_search, only: [:edit, :update, :destroy]
  before_filter :authenticate_user!
  after_action :verify_authorized
  
  def index
    @top_searches = TopSearch.normal.page(params[:page])
    authorize TopSearch
  end

  def new
    @top_search = TopSearch.new
    authorize @top_search
    render :form
  end

  def create
    @top_search = TopSearch.new(top_search_params)
    authorize @top_search
    if @top_search.save
      flash[:success] = '新建成功！'
      redirect_to top_searches_path
    else
      flash[:danger] = '新建失败！'
      redirect_to :back
    end
  end

  def edit
    authorize @top_search
    render :form
  end

  def update
    authorize @top_search
    if @top_search.update(top_search_params)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to top_searches_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    authorize @top_search
    @top_search.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  private 
    def set_top_search
      @top_search = TopSearch.find_by(id: params[:id])
    end

    def top_search_params
      params.require(:top_search).permit(:name)
    end
end
