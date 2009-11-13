class WidgetsController < ApplicationController
  def self.convert_colors(colors)
    colors.collect do |color|
      color.downcase!
      color.strip!

      case(color)
      when /^#([0-9a-f])([0-9a-f])([0-9a-f])$/
        "#"+($1*2)+($2*2)+($3*2)
      when /^#[0-9a-f]{6}/i
        color.downcase
      else
        (hex=HTML_COLORS[color.downcase]) ? hex : color
      end
    end
  end

  SEARCH_WIDGET_DEFAULTS = {
    :font_family      => 'serif',
    :width            => '180px',
    :background_color => '#222222',
    :height           => '64px',
    :text_color       => '#ffffff',
    :hint_color       => '#999999',
    :font_size        => '15px',
    :input_font_size  => '14px',
    :locale           => nil
  }

  COLOR_PALETTE = %w{black blue green indigo orange red violet white yellow #222 #999}

  DEFAULT_OPTIONS = {
    :background_color => WidgetsController.convert_colors(COLOR_PALETTE),
    :text_color       => WidgetsController.convert_colors(COLOR_PALETTE),
    :hint_color       => WidgetsController.convert_colors(COLOR_PALETTE),
    :font_family      => %w{serif sans-serif},
    :font_size        => %w{14px 15px},
    :input_font_size  => %w{14px 15px},
    :height           => %w{64px 80px 100px 120px},
    :width            => %w{180px 200px 250px 300px 350px 400px},
    :locale           => nil
  }

  def customize_search
    @widget_params = filter_params(SEARCH_WIDGET_DEFAULTS)
    @widget_inputs = [:background_color, :text_color, :hint_color, :font_family, :font_size, :input_font_size, :height, :width]
    @locales       = [['English', 'en'], ['Deutsch (German)', 'de'], ['日本語 (Japanese)', 'ja'], ['Portugu&ecirc;s (Portuguese)', 'pt'], ['Svenska (Swedish)', 'sv']]

    if params[:url]
      collector = CssCollector.new('background-color', 'color', 'font-family', 'font-size', 'height', 'width')
      url = params[:url] =~ %r{^http://} ? params[:url] : "http://#{params[:url]}"
      collector.collect_html(url)

      colors = WidgetsController.convert_colors(collector[:color] + collector['background-color'])
      colors.uniq!
      colors.sort!

      @widget_options = {
        :background_color => colors,
        :text_color => colors,
        :hint_color => colors,
        :font_family => collector['font-family'].sort,
        :font_size => collector['font-size'].sort,
        :input_font_size => collector['font-size'].sort,
        :height => collector[:height].sort,
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
end
