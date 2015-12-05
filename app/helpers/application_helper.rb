module ApplicationHelper

  def link_to_add_associations(*args, &block)
    name = args[0] || 'Add'

    html_options = args[1] || {}
    html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
    html_options[:'data-max'] = html_options['data-max'] || ""
    html_options[:'data-association-insertion-template'] = raw(CGI.escapeHTML(capture(&block)))

    link_to(name, '#', html_options)
  end

end
