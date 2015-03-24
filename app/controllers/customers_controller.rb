class CustomersController < ApplicationController
  unloadable
  layout 'base'
  before_filter :find_project, :only => [:select, :assign]
  before_filter :authorize, :only => [:select, :assign]
  before_filter :authorize_global
  before_filter :find_customer, :only => [:edit, :update, :destroy]
  before_filter :find_customers, :only => [:index, :select]
 
  def show
    @customer = Customer.find_by_id(@project.customer_id)
  end
  
  def index
  end

  def select
  end
  
  def assign
    @project.customer_id = params[:customer][:id]
    if @project.save
      flash[:notice] = l(:notice_successful_save)
      redirect_to :action => "show", :id => params[:id]
    else
      flash[:notice] = l(:notice_unsuccessful_save)
      redirect_to :action => "select", :id => params[:id]
    end
  end
    
  def edit
  end

  def update
    if @customer.update_attributes(customer_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    if @customer.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
    redirect_to :action => "index"
  end
  
  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  private
  
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_customer
    @customer = Customer.find_by_id(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_customers
    @customers = Customer.all
  end

  def customer_params
    params.require(:customer).
      permit(:name, :company, :address, :phone, :email, :website, :skype_name)
  end
end
