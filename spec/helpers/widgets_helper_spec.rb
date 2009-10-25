require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WidgetsHelper do
  describe :widget_params_url do
    before :each do
      params[:action] = 'customize_search'
    end

    it 'calls widgets_url' do
      helper.should_receive(:widgets_url).and_return(:widgets_url)
      helper.widget_params_url.should == :widgets_url
    end

    it 'passes @widget_params to widgets_url' do
      assigns[:widget_params] = {:foo => 'bar', :baz => 'xyzzy'}

      helper.should_receive(:widgets_url).with(hash_including(:foo => 'bar', :baz => 'xyzzy')).and_return(:widgets_url)

      helper.widget_params_url.should == :widgets_url
    end

    it 'merges params[:action] into the params' do
      params[:action] = 'search'

      helper.should_receive(:widgets_url).with(hash_including(:action => 'search')).and_return(:widgets_url)

      helper.widget_params_url.should == :widgets_url
    end

    it 'filters out blank values' do
      assigns[:widget_params] = {:foo => 'bar', :baz => '', :xyzzy => nil}

      helper.should_receive(:widgets_url).with(hash_including(:foo => 'bar', :format => 'js')).and_return(:widgets_url)

      helper.widget_params_url.should == :widgets_url
    end

    it 'filters out params that map to defaults' do
      assigns[:widget_params] = WidgetsController::SEARCH_WIDGET_DEFAULTS

      helper.should_receive(:widgets_url).with(hash_including(:format => 'js')).and_return(:widgets_url)

      helper.widget_params_url.should == :widgets_url
    end

    it 'adds a format of "js"' do
      helper.should_receive(:widgets_url).with(hash_including(:format => 'js')).and_return(:widgets_url)

      helper.widget_params_url.should == :widgets_url
    end
  end
end
