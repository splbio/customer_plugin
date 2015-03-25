# Redmine customer plugin
require 'redmine'

Redmine::Plugin.register :customer_plugin do
  name 'Customer plugin'
  author 'Eric Davis'
  description 'This is a plugin for Redmine that can be used to track basic customer information'
  version '0.2.0'

  url 'https://projects.littlestreamsoftware.com/projects/redmine-customers' if respond_to? :url
  author_url 'http://www.littlestreamsoftware.com' if respond_to? :author_url

  
  project_module :customer_module do
    permission :view_customer, {:customers => [:show]}
    permission :assign_customer, {:customers => [:assign, :select]}
    permission :see_customer_list, {:customers => [:index]}
    permission :edit_customer, {:customers => [:edit, :update, :new, :create, :destroy]}
    permission :assign_customer_to_issue, {:customers => [:autocomplete], :customer_issues => [:create, :destroy]}

  end

  menu :top_menu, :customers, {:controller => 'customers', :action => 'index'}, :caption => :label_customer_plural
  menu :project_menu, :customers, {:controller => 'customers', :action => 'show'}, :caption => :customer_title
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'issue'
  end
else
  Dispatcher.to_prepare :customer_plugin do
    require_dependency 'issue'
  end
end

Issue.send(:include, CustomerPlugin::IssuePatch)

require 'customer_plugin/view_issues_show_description_bottom_hook'
