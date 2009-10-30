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

  describe :customize_search do
    describe 'when url is provided' do
      it 'collects html on the url' do
        collector = mock(CssCollector)
        CssCollector.should_receive(:new).with('color', 'font-family', 'height', 'text-color', 'width').
          and_return(collector)

        collector.should_receive(:collect_html).with('http://example.com/')

        collector.stub!(:[]).and_return([])

        get :customize_search, :url => 'http://example.com/'
      end
    end
  end
end
