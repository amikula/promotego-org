require File.dirname(__FILE__) + '/../../spec_helper'

describe String do
  describe :sluggify do
    it "replaces spaces in the string with dashes" do
      'foo bar'.sluggify.should == 'foo-bar'
    end

    it "downcases the result" do
      'Foo Bar'.sluggify.should == 'foo-bar'
    end

    it "converts non-letters into dashes" do
      'a.b.c'.sluggify.should == 'a-b-c'
    end

    it 'converts multiple dashes to single dash' do
      'a..b..c---d'.sluggify.should == 'a-b-c-d'
    end

    it 'strips leading dashes' do
      '--a-b'.sluggify.should == 'a-b'
    end

    it 'strips trailing dashes' do
      'abc-def...'.sluggify.should == 'abc-def'
    end

    it 'converts underscores to dashes' do
      'foo_bar'.sluggify.should == 'foo-bar'
    end

    it 'converts non-ascii characters to dashes' do
      '19√Go Club'.sluggify.should == '19-go-club'
    end
  end
end
