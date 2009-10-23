module WidgetsHelper
  def widget_params_url
    url_params = (@widget_params || {}).merge(:action => params[:action].sub('customize_', ''), :format => 'js')
    url_params.delete_if{|k,v| v.blank? || WidgetsController::SEARCH_WIDGET_DEFAULTS[k] == v}

    widgets_url(url_params)
  end
end
