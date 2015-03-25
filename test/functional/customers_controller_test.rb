require File.dirname(__FILE__) + '/../test_helper'

class CustomersControllerTest < ActionController::TestCase
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

  # TODO: Other actions

  context "#autocomplete without permission" do
    should "return unauthorized" do
      get :autocomplete, :id => @project.id, :term => "match"

      assert_response 403
    end
  end

  context "#autocomplete with permission" do
    setup do
      @role = Role.generate!(:name => 'Customer MGMT', :permissions => [:assign_customer_to_issue, :view_issues, :edit_issues])
      User.add_to_project(@user, @project, [@role])
      @customer_match = Customer.generate!(:name => "Match")
      @customer_not = Customer.generate!(:name => "Nope")
      @customer_match_company = Customer.generate!(:company => "Match")
    end

    should "find matching customers" do
      get :autocomplete, :id => @project.id, :term => "match"

      assert_response :success

      assert assigns(:customers).include?(@customer_match)
      refute assigns(:customers).include?(@customer_not)
      assert assigns(:customers).include?(@customer_match_company)
    end

    should "return JSON" do
      get :autocomplete, :id => @project.id, :term => "match"

      assert_response :success

      json = ActiveSupport::JSON.decode(response.body)
      assert_kind_of Array, json
      customer = json.first
      assert_kind_of Hash, customer
      assert_equal @customer_match.id, customer['value']
      assert_equal @customer_match.pretty_name, customer['label']
    end
  end

end
