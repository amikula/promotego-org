require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WidgetsController do
  it 'assigns widget_params by filtering the params hash against SEARCH_WIDGET_DEFAULTS' do
    get :search, :font_family => 'serif', :width => '42'

    assigns[:widget_params][:font_family].should == 'serif'
    assigns[:widget_params][:width].should == '42'
  end

  it 'assigns defaults to SEARCH_WIDGET_DEFAULTS' do
    get :search

    assigns[:widget_params].should == WidgetsController::SEARCH_WIDGET_DEFAULTS
  end

  it 'does not assign params not in the defaults hash' do
    get :search, :bogus_param => 'bogus_value'

    assigns[:widget_params][:bogus_param].should be_nil
  end

  describe :convert_colors do
    it 'converts 3-digit hex colors to 6-digit hex colors' do
      WidgetsController.convert_colors(%w{#fff #123}).should == %w{#ffffff #112233}
    end

    it 'leaves lowercase 6-digit hex colors alone' do
      WidgetsController.convert_colors(%w{#ffffff #122334}).should == %w{#ffffff #122334}
    end

    it 'converts uppercase 6-digit to lowercase' do
      WidgetsController.convert_colors(%w{#FFFFFF #ABCDEF}).should == %w{#ffffff #abcdef}
    end

    it 'converts html color names to hexadecimal' do
      WidgetsController.convert_colors(%w{yellow white green brown}).should == %w{#ffff00 #ffffff #008000 #a52a2a}
    end
  end

  describe :customize_search do
    describe 'when url is provided' do
      it 'collects html on the url' do
        collector = mock(CssCollector)
        CssCollector.should_receive(:new).with('background-color', 'color', 'font-family', 'font-size', 'height', 'width').
          and_return(collector)
        collector.should_receive(:collect_html).with('http://example.com/')

        collector.stub!(:[]).and_return([])

        get :customize_search, :url => 'http://example.com/'
      end
    end
  end
end
