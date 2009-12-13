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
      I18n.default_locale.should == :en

      subject.should_receive(:extract_locale_from_subdomain).and_return(nil)

      subject.host_locale.should == :en
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

  describe :merge_location_hashes do
    it 'looks up the translation requested' do
      subject.merge_translation_hashes(:US, :provinces, :en).keys.length.should == 51
      subject.merge_translation_hashes(:US, :provinces, :en)[:CA].should == 'California'
    end

    it 'merges keys according to fallback sequence' do
      subject.merge_translation_hashes(:US, :provinces, :sv).keys.length.should == 51
      subject.merge_translation_hashes(:US, :provinces, :sv)[:CA].should == 'Kalifornien'
    end
  end
end
