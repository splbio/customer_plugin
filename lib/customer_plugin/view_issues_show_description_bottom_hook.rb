module CustomerPlugin
  class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener

    def url_for(options={})
      if options.is_a? String
        escape_once(options)
      else
        super
      end
    end
    
    # * issue
    def view_issues_show_description_bottom(context={})
      return '' if context[:issue].project.nil?
      return '' unless User.current.allowed_to?(:view_customer, context[:issue].project)
      
      return context[:controller].send(:render_to_string,
                                       :partial => 'customers/issue_section',
                                       :layout => false,
                                       :locals => {:issue => context[:issue]})
    end
  end
end
