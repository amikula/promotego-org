require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do
  before(:each) do
    @params = {}
    subject.stub!(:params).and_return(@params)
    subject.stub!(:extract_locale_from_subdomain)
  end

  describe :set_locale do
    it 'uses params[:locale] if present' do
      @params[:locale] = 'foo'
      I18n.should_receive(:locale=).with('foo')

      subject.set_locale
    end

    it 'uses the preferred language from the browser if present' do
      mock_request = mock('request')
      mock_request.should_receive(:preferred_language_from).with(I18n.available_locales).and_return('bar')
      subject.should_receive(:request).and_return(mock_request)
      I18n.should_receive(:locale=).with('bar')

      subject.set_locale
    end

    it 'overrides browser language with params[:locale] if present' do
      @params[:locale] = 'foo'
      mock_request = mock('request')
      mock_request.stub!(:preferred_language_from).with(I18n.available_locales).and_return('bar')
      subject.stub!(:request).and_return(mock_request)
      I18n.should_receive(:locale=).with('foo')

      subject.set_locale
    end

    it 'uses subdomain if present' do
      subject.stub!(:extract_locale_from_subdomain).and_return('baz')

      I18n.should_receive(:locale=).with('baz')

      subject.set_locale
    end

    it 'overrides subdomain with params[:locale] if present' do
      @params[:locale] = 'foo'
      subject.stub!(:extract_locale_from_subdomain).and_return('baz')
      I18n.should_receive(:locale=).with('foo')

      subject.set_locale
    end
  end

  describe :subdomain_locale? do
    it 'returns false if extract_locale_from_subdomain is nil' do
      subject.should_receive(:extract_locale_from_subdomain).and_return(nil)

      subject.subdomain_locale?.should be_false
    end

    it 'returns true if extract_locale_from_subdomain is not nil' do
      subject.should_receive(:extract_locale_from_subdomain).and_return('en')

      subject.subdomain_locale?.should be_true
    end
  end

  describe :host_locale do
    it 'returns locale extracted from subdomain' do
      subject.stub!(:extract_locale_from_subdomain).and_return('de')

      subject.host_locale.should == :de
    end

    it 'returns default locale when locale from subdomain is nil' do
      I18n.default_locale.should == :'en-US'

      subject.should_receive(:extract_locale_from_subdomain).and_return(nil)

      subject.host_locale.should == :'en-US'
    end
  end

  describe :locale_redirect do
    it 'redirects to the base hostname if the browser locale matches the host locale' do
      subject.stub!(:extract_locale_from_subdomain).and_return ('en')
      subject.request.stub!(:preferred_language_from).and_return(:en)
      subject.stub!(:base_hostname).and_return('example.com')

      subject.should_receive(:redirect_to)

      subject.locale_redirect
    end

    it 'redirects to the base hostname if the browser locale starts with the host locale' do
      subject.stub!(:extract_locale_from_subdomain).and_return ('en')
      subject.request.stub!(:preferred_language_from).and_return(:'en-US')
      subject.stub!(:base_hostname).and_return('example.com')

      subject.should_receive(:redirect_to)

      subject.locale_redirect
    end

    it 'does not redirect to the base hostname if the browser locale does not match the host locale' do
      subject.stub!(:extract_locale_from_subdomain).and_return ('de')
      subject.request.stub!(:preferred_language_from).and_return(:'en-US')

      subject.should_not_receive(:redirect_to)

      subject.locale_redirect
    end
  end

  describe :base_hostname do
    it 'strips known locales from the hostname' do
      subject.stub!(:request).and_return(mock('request', :host => 'de.example.com'))

      subject.base_hostname.should == 'example.com'
    end

    it 'returns the hostname untouched if no locale is present' do
      subject.stub!(:request).and_return(mock('request', :host => 'promotego.org'))

      subject.base_hostname.should == 'promotego.org'
    end
  end

  describe :seo_encode do
    it 'converts spaces to hyphens' do
      subject.seo_encode('United States of America').should == 'United-States-of-America'
    end
  end

  describe :seo_decode do
    it 'converts hyphens to spaces' do
      subject.seo_decode('United-States-of-America').should == 'United States of America'
    end
  end

  describe :distance_units do
    it 'uses the current locale setting, converting to symbol' do
      I18n.should_receive(:t).with(:distance, :scope => :locale_units).and_return('km')

      subject.distance_units.should == :km
    end
  end
end
