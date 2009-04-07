require File.join(File.dirname(__FILE__), 'spec_helper')

# Note: these specs mainly cover exception handling and the
#       expected outcome of the configuration/settings. To 
#       really test the functionality, once installed in an
#       application, specs should be written that directly
#       relate to the models of the application.

# config according to sample models specified in spec_helper
RPH::EasySearch::Setup.config do
  setup_tables do
    users    :first_name, :last_name, :email
    projects :title, :description
    groups   :name, :description
  end
end

describe "EasySearch" do  
  EZS = RPH::EasySearch
  
  it "Search class should have EasySearch functionality" do
    Search.included_modules.include?(RPH::EasySearch).should be_true
  end
  
  it "should override initialize to expect a class name attr" do
    Search.new rescue ArgumentError; true
  end
  
  it "should return blank search results (an empty array) for missing keywords" do
    results = Search.users.with('')
    results.should be_an_instance_of(Array)
    results.should be_empty
  end
  
  describe "table_settings configuration" do
    before(:each) do      
      @table_settings = RPH::EasySearch::Setup.table_settings
    end
    
    it "should return nil if no block is given" do
      config = EZS::Setup.config
      config.should be_nil
    end
        
    it "should have three models in EasySearch configuration" do
      @table_settings.keys.size.should eql(3)
    end
    
    it "should have keys mapped to plural versions of model names" do
      @table_settings.keys.include?('users').should be_true
      @table_settings.keys.include?('projects').should be_true
      @table_settings.keys.include?('groups').should be_true
    end
    
    it "should have indifferent access to tables/columns in Setup.settings hash" do
      @table_settings.should be_an_instance_of(HashWithIndifferentAccess)
      @table_settings[:users].should eql(@table_settings['users'])
      @table_settings[:projects].should eql(@table_settings['projects'])
      @table_settings[:groups].should eql(@table_settings['groups'])
    end
    
    it "should have the correct number of columns for each table name" do
      @table_settings[:users].size.should eql(3)
      @table_settings[:projects].size.should eql(2)
      @table_settings[:groups].size.should eql(2)
    end
    
    it "should have instances of Array as the values in the Setup.settings hash" do
      @table_settings[:users].should be_an_instance_of(Array)
      @table_settings[:projects].should be_an_instance_of(Array)
      @table_settings[:groups].should be_an_instance_of(Array)
    end
    
    it "should specify :first_name, :last_name, :email as the columns to search for 'users' table" do
      @table_settings[:users].include?(:first_name).should be_true
      @table_settings[:users].include?(:last_name).should be_true
      @table_settings[:users].include?(:email).should be_true
    end
    
    it "should specify :title, :description as the columns to search for 'projects' table" do
      @table_settings[:projects].include?(:title).should be_true
      @table_settings[:projects].include?(:description).should be_true
    end
    
    it "should specify :name, :description as the columns to search for 'groups' table" do
      @table_settings[:groups].include?(:name).should be_true
      @table_settings[:groups].include?(:description).should be_true
    end
  end
  
  describe "strip_keywords configuration" do
    after(:each) do
      # reset dull keywords to defaults
      EZS::Setup.config do
        strip_keywords(true) { EZS::DEFAULT_DULL_KEYWORDS }
      end
    end
    
    it "should have default dull keywords" do
      EZS::Setup.dull_keywords.should eql(EZS::DEFAULT_DULL_KEYWORDS)
    end
    
    it "should be an instance of Array" do
      EZS::Setup.dull_keywords.should be_an_instance_of(Array)
    end
    
    it "should support adding new dull keywords to the list" do
      more_dull_keywords = ['something', 'else']
      EZS::Setup.config { strip_keywords { more_dull_keywords } }
      
      EZS::Setup.dull_keywords.should eql(EZS::DEFAULT_DULL_KEYWORDS + more_dull_keywords)
    end
    
    it "should support overwriting the dull keywords completely" do
      new_dull_keywords = ['whatever', 'i', 'want']
      EZS::Setup.config { strip_keywords(true) { new_dull_keywords } }
      
      EZS::Setup.dull_keywords.should eql(new_dull_keywords)
    end
    
    it "should not have duplicate dull keywords" do
      duplicate_default_keywords = EZS::DEFAULT_DULL_KEYWORDS
      EZS::Setup.config { strip_keywords { duplicate_default_keywords } }
      
      EZS::Setup.dull_keywords.should eql(EZS::DEFAULT_DULL_KEYWORDS)
    end
  end
  
  describe "search terms" do
    def extract(terms)
      Search.new(:users).send(:extract, terms)
    end
    
    def strip_emails_from(text)
      Search.new(:users).send(:strip_emails_from, text)
    end
    
    it "should separate terms when parsing search terms" do
      extract('ryan heath').should eql(['ryan', 'heath'])
    end
    
    it "should not search dull keywords" do
      extract('ryan a the and or heath').should eql(['ryan', 'heath'])
    end
    
    it "should return an empty array if all keywords are dull" do
      extract('a the and or').should eql([])
    end
    
    it "should remove any conflicting apostrophe's in search terms" do
      extract("ryan's stuff").should eql(['ryans', 'stuff'])
    end
    
    it "should keep emails intact when contained within search terms" do
      extract('ryan rph@test.com heath').should eql(['ryan', 'heath', 'rph@test.com'])
    end
    
    it "should pull out dull keywords even if they're uppercase" do
      extract('ryan A THE AND OR').should eql(['ryan'])
    end
    
    it "should pull out the emails from the search terms" do
      strip_emails_from('ryan rph@test.com rph@other.com').
        should eql(['rph@test.com', 'rph@other.com'])
    end
    
    it "should not have any emails to pull out of the search terms" do
      strip_emails_from('ryan heath').should eql([])
    end
  end
  
  describe "errors" do    
    it "should raise NoModelError if a model (constant) cannot be found" do
      EZS::Setup.config { setup_tables { wrong :first, :last } }
      Search.send(:include, RPH::EasySearch) rescue EZS::NoModelError; true
    end
    
    it "should raise InvalidActiveRecordModel error if model doesn't descend from ActiveRecord" do
      Search.new(:wrong) rescue EZS::InvalidActiveRecordModel; true
    end
    
    it "should raise InvalidActiveRecordModel error if constant/model doesn't exist" do
      Search.whatever.with("wrong") rescue EZS::InvalidActiveRecordModel; true
    end
    
    it "should raise InvalidSettings error if there are no specified columns for a given model" do
      class Sample < ActiveRecord::Base; end
      Search.sample.with("something") rescue EZS::InvalidSettings; true
    end
    
    it "should raise InvalidDullKeywordsType error if something other than an array is passed to strip_keywords" do
      EZS::Setup.config { strip_keywords { {'something' => 'else'} } } rescue EZS::InvalidDullKeywordsType; true
      EZS::Setup.config { strip_keywords { '' } } rescue EZS::InvalidDullKeywordsType; true
      EZS::Setup.config { strip_keywords { nil } } rescue EZS::InvalidDullKeywordsType; true
    end
  end
end