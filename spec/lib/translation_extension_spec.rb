require File.dirname(__FILE__) + '/../spec_helper'

describe TranslationExtension do
  class TestClass
    include TranslationExtension
  end

  def subject
    @subject ||= TestClass.new
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

  describe :has_provinces? do
    it 'returns true when the country has provinces in the province hash' do
      subject.should_receive(:merge_translation_hashes).with(:US, :provinces).and_return(:CA => 'California')

      subject.has_provinces?(:US).should be_true
    end

    it 'returns true when the country is not listed in the province hash' do
      subject.should_receive(:merge_translation_hashes).with(:XX, :provinces).and_return(nil)

      subject.has_provinces?(:XX).should be_true
    end

    it 'returns false when the country has the special province "none" in the province hash' do
      subject.should_receive(:merge_translation_hashes).with(:SE, :provinces).and_return(:none => 'true')

      subject.has_provinces?(:SE).should be_false
    end
  end
end
