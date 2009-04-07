module RPH
  module EasySearch
    class Error < RuntimeError
      def self.message(msg=nil); msg.nil? ? @message : self.message = msg; end
      def self.message=(msg); @message = msg; end
    end
    
    # raised when a model is attempted to be configured, but doesn't exist
    class NoModelError < Error
      message "you've specified a model that doesn't exist"; end
      
    # raised when any model (consant) is derived from the `Setup.config' block
    # and is not a subclass of ActiveRecord::Base
    class InvalidActiveRecordModel < Error
      message "all models specified in `Setup.config' must descend from ActiveRecord"; end
      
    # raised when a model has not been configured, but is attempted to be searched
    # (each model used with EasySearch has to be configured, meaning, the columns
    #  to be searched for that model must be set)
    class InvalidSettings < Error
      message "you must specify all Models and the fields to search for each Model in the `Setup.config' block"; end
    
    # raised when block passed to `Setup.strip_keywords' does not evaluate as an instance of Array
    class InvalidDullKeywordsType < Error
      message "specified keywords must be of type Array in the `Setup.strip_keywords' block"; end
  end
end