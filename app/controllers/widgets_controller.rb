class WidgetsController < ApplicationController
  def search
    respond_to do |format|
      format.html
      format.js do
        javascript_widget = @template.escape_javascript(render_to_string :partial => 'search_widget')
        render :text => "document.write('#{javascript_widget}')", :content_type => "text/javascript"
      end
    end
  end
end
