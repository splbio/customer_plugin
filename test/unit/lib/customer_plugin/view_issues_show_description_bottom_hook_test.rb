require File.dirname(__FILE__) + '/../../../test_helper'

class CustomerPlugin::ViewIssuesShowDescriptionBottomTest < ActionController::TestCase
  fixtures :projects, :users, :email_addresses,
           :trackers, :projects_trackers,
           :enabled_modules,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values

  include Redmine::Hook::Helper

  def controller
    @controller ||= ApplicationController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  
  def hook(args={})
    call_hook :view_issues_show_description_bottom, args
  end

  context "#view_issues_show_description_bottom for a user without permission" do
    setup do
      @project = Project.generate!
      @issue = Issue.generate!(:project => @project)
      User.current = nil
    end

    should "return an empty string" do
      assert hook(:issue => @issue).blank?, "Non blank response returned."
    end
  end

  context "#view_issues_show_description_bottom for a user with permission" do
    setup do
      @project = Project.generate!
      @project.enabled_module_names = ['issue_tracking', 'customer_module']
      
      @issue = Issue.generate!(:project => @project)
      @role = Role.generate!(:name => 'Customer viewer', :permissions => [:view_customer])
      @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')

      User.add_to_project(@user, @project, [@role])
      User.current = @user.reload
    end
    
    should "return an hr" do
      @response.body = hook(:issue => @issue)

      assert_select 'hr'
    end

    should "return a div for the section" do
      @response.body = hook(:issue => @issue)
      
      assert_select 'div.customers'
    end

    should "return the label for the section" do
      @response.body = hook(:issue => @issue)

      assert_select 'p strong', :text => 'Customer List'
    end

    context "for an issue with customers" do
      setup do
        @customer1 = Customer.generate!(:name => "Eric Davis")
        @customer2 = Customer.generate!(:company => "Little Stream Software")

        @issue.customers << [@customer1, @customer2]
      end

      should "list of the customer names" do
        @response.body = hook(:issue => @issue)

        assert_select 'table' do
          assert_select 'td', :text => @customer1.pretty_name
          assert_select 'td', :text => @customer2.pretty_name
        end
      end

    end
  end
end
