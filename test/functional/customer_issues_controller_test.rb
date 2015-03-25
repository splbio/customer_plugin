require File.dirname(__FILE__) + '/../test_helper'

class CustomerIssuesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :email_addresses,
           :trackers, :projects_trackers,
           :enabled_modules,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values

  def setup
    @project = Project.generate!
    @project.enabled_module_names = ['issue_tracking', 'customer_module']
    @issue = Issue.generate!(:project => @project).reload
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')

    @request.session[:user_id] = @user.id

  end

  context "#create without permission" do
    should "return not found" do
      post :create

      assert_response 404
    end
  end

  context "#create with permission" do
    setup do
      @role = Role.generate!(:name => 'Customer MGMT', :permissions => [:assign_customer_to_issue, :view_issues, :edit_issues])
      User.add_to_project(@user, @project, [@role])
      @customer = Customer.generate!
    end

    should "associate an Issue and a Customer" do
      post :create, :customer_issue => { :issue_id => @issue.id, :customer_id => @customer.id }

      assert_response 302
      assert_redirected_to issue_path(@issue)

      @issue.reload
      @customer.reload
      assert_equal [@customer], @issue.customers.all
      assert_equal [@issue], @customer.issues.all
    end

    should "return a 404 if Issue is missing" do
      post :create, :customer_issue => { :issue_id => 65000, :customer_id => @customer.id }

      assert_response 404
    end

    should "return a 404 if Customer is missing" do
      post :create, :customer_issue => { :issue_id => @issue.id, :customer_id => 65000 }

      assert_response 404
    end

    should "do nothing if they are already associated" do
      @customer.issues << @issue

      post :create, :customer_issue => { :issue_id => @issue.id, :customer_id => @customer.id }

      assert_response 302
      assert_redirected_to issue_path(@issue)

      @issue.reload
      @customer.reload
      assert_equal [@customer], @issue.customers.all
      assert_equal [@issue], @customer.issues.all
    end
    
  end

  context "#destroy without permission" do
    should "return not found" do
      delete :destroy, :id => 10

      assert_response 404
    end
  end

  context "#destroy with permission" do
    setup do
      @role = Role.generate!(:name => 'Customer MGMT', :permissions => [:assign_customer_to_issue, :view_issues, :edit_issues])
      User.add_to_project(@user, @project, [@role])
      @customer = Customer.generate!
    end

    should "remove an association between an Issue and a Customer" do
      @customer.issues << @issue
      delete :destroy, :customer_issue => { :issue_id => @issue.id, :customer_id => @customer.id }

      assert_response 302
      assert_redirected_to issue_path(@issue)

      @issue.reload
      @customer.reload
      assert @issue.customers.empty?
      assert @customer.issues.empty?
    end

    should "return a 404 if Issue is missing" do
      delete :destroy, :customer_issue => { :issue_id => 65000, :customer_id => @customer.id }

      assert_response 404
    end

    should "return a 404 if Customer is missing" do
      delete :destroy, :customer_issue => { :issue_id => @issue.id, :customer_id => 65000 }

      assert_response 404
    end

    should "do nothing if they are not associated" do
      delete :destroy, :customer_issue => { :issue_id => @issue.id, :customer_id => @customer.id }

      assert_response 302
      assert_redirected_to issue_path(@issue)

      @issue.reload
      @customer.reload
      assert @issue.customers.empty?
      assert @customer.issues.empty?

    end
  end

end
