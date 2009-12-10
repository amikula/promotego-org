require File.dirname(__FILE__) + '/../spec_helper'

describe ReverseTranslations do
  describe :go do
    it 'reverses a hash, converting values to strings' do
      ReverseTranslations.go(:foo => :bar, :baz => :xyzzy).should == {:bar => 'foo', :xyzzy => 'baz'}
    end

    it 'converts keys to symbols' do
      ReverseTranslations.go('foo' => 'bar').should == {:bar => 'foo'}
    end

    it 'reverses only the lowest level of nested hashes' do
      ReverseTranslations.go(:foo => {:bar => :baz}, :xyzzy => :thud).should == {:foo => {:baz => 'bar'}, :thud => 'xyzzy'}
    end
  end
end
