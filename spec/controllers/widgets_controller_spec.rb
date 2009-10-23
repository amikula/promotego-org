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
end
