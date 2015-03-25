class CustomerIssuesController < ApplicationController
  before_filter :find_issue
  before_filter :authorize
  before_filter :find_customer

  def create
    # Open to race conditions but that's not a big deal for this association
    unless @customer.issues.include?(@issue)
      @customer.issues << @issue
    end

    respond_to do |format|
      format.html { redirect_to issue_path(@issue) }
      format.js { @issue.reload }
    end
  end

  def destroy
    # Open to race conditions but that's not a big deal for this association
    @customer.issues.destroy(@issue)

    respond_to do |format|
      format.html { redirect_to issue_path(@issue) }
      format.js { @issue.reload }
    end
  end

  private

  # Find the issue whose id is the :issue_id parameter
  # Raises a Unauthorized exception if the issue is not visible
  def find_issue
    @issue = Issue.find(customer_issue_params[:issue_id])
    raise Unauthorized unless @issue && @issue.visible?
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_customer
    @customer = Customer.find(customer_issue_params[:customer_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def customer_issue_params
    (params[:customer_issue] || ActionController::Parameters.new({})).
      permit(:issue_id, :customer_id)
  end
end
