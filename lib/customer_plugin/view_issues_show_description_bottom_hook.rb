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
      
      html = '<hr />'
      inner_section = ''
      inner_section << content_tag(:p, content_tag(:strong, l(:label_customer_plural)))

      if context[:issue].customers.present?
        items = context[:issue].customers.inject('') do |list, customer|
          list << content_tag(:tr,
                              content_tag(:td,
                                          customer.pretty_name))
          list
        end
        
        inner_section << content_tag(:table, items.html_safe, :style => 'width: 100%')
      end
      
      html << content_tag(:div, inner_section.html_safe, :class => 'customers')

      return html
    end
  end
end
