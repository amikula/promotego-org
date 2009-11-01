class WidgetsController < ApplicationController
  SEARCH_WIDGET_DEFAULTS = {
    :font_family => 'serif',
    :width => '180px',
    :background_color => '#222222',
    :height => '64px',
    :text_color => '#ffffff',
    :dim_color => '#999999'
  }

  COLOR_PALETTE = %w{black blue green indigo orange red violet white yellow #222 #999}

  DEFAULT_OPTIONS = {
    :background_color => COLOR_PALETTE,
    :dim_color        => COLOR_PALETTE,
    :font_family      => %w{serif sans-serif},
    :height           => %w{64px 80px 100px 120px},
    :text_color       => COLOR_PALETTE,
    :width            => %w{180px 200px 250px 300px 350px 400px}
  }

  def customize_search
    @widget_params = filter_params(SEARCH_WIDGET_DEFAULTS)

    if params[:url]
      collector = CssCollector.new('background-color', 'color', 'font-family', 'height', 'width')
      collector.collect_html(params[:url])

      colors = (collector[:color] + collector['background-color']).sort
      colors.uniq!
      colors = WidgetsController.convert_colors(colors)

      @widget_options = {
        :background_color => colors,
        :dim_color => colors,
        :font_family => collector['font-family'].sort,
        :height => collector[:height].sort,
        :text_color => colors,
        :width => collector[:width].sort
      }
    else
      @widget_options = DEFAULT_OPTIONS
    end

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

  def self.convert_colors(colors)
    colors.collect do |color|
      color.downcase!
      color.strip!

      case(color)
      when /^#([0-9a-f]([0-9a-f]))([0-9a-f])$/
        "#"+($1*2)+($2*2)+($3*2)
      else
        color
      end
    end
  end
end
