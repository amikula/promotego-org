class WidgetsController < ApplicationController
  SEARCH_WIDGET_DEFAULTS = {
    :font_family => 'serif',
    :width => '180px',
    :background_color => '#222',
    :height => '64px',
    :text_color => '#fff',
    :dim_color => '#999'
  }

  COLOR_PALETTE = %w{black blue green indigo orange red violet white yellow #222 #999}

  DEFAULT_OPTIONS = {
    :font_family      => %w{serif sans-serif},
    :width            => %w{180px 200px 250px 300px 350px 400px},
    :background_color => COLOR_PALETTE,
    :height           => %w{64px 80px 100px 120px},
    :text_color       => COLOR_PALETTE,
    :dim_color        => COLOR_PALETTE
  }

  def customize_search
    @widget_params = filter_params(SEARCH_WIDGET_DEFAULTS)
    respond_to do |format|
      format.html
      format.js { @javascript_widget = @template.escape_javascript(render_to_string(:partial => 'search_widget')) }
    end
  end

  def search
    @widget_params = filter_params(SEARCH_WIDGET_DEFAULTS)

    respond_to do |format|
      format.html
      format.js do
        javascript_widget = @template.escape_javascript(render_to_string(:partial => 'search_widget'))
        render :text => "document.write('#{javascript_widget}')", :content_type => "text/javascript"
      end
    end
  end

private
  def filter_params(defaults)
    returning({}) do |h|
      defaults.each_pair do |k,v|
        h[k] = params[k].blank? ? v : params[k]
      end
    end
  end
end
