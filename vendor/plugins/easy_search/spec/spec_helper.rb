require 'rubygems'
require 'active_record'
require 'ostruct'
require File.join(File.dirname(__FILE__), "../lib/easy_search")
 
# fake ActiveRecord class to avoid dealing
# with actual DB connections
module MockAR
  class Base < ActiveRecord::Base
    self.abstract_class = true
    
    # want this class to act like ActiveRecord
    def descends_from_active_record?
      true 
    end
    
    # mock out the find to simulate real
    # ActiveRecord objects being returned from DB
    def self.find(*args)
      mock_fields
    end
    
    private
      def self.mock_fields
        [
          OpenStruct.new({ :title => 'Ryan' }),
          OpenStruct.new({ :title => 'Paul' }),
          OpenStruct.new({ :title => 'Heath' })
        ]
      end
  end
end

class Search
  include RPH::EasySearch
end

class User < MockAR::Base; end
class Project < MockAR::Base; end
class Group < MockAR::Base; end