%w(constants errors setup validations).each do |f| 
  require File.join(File.dirname(__FILE__), f)
end

module RPH
  module EasySearch
    def self.included(base)
      base.send(:extend,  ClassMethods)
      base.send(:include, InstanceMethods)
      
      # before continuing, validate that the models identified (if any) in the 
      # setup_tables block (within `Setup.config') exist and are valid ActiveRecord descendants
      Validations.validate_settings!
    end
    
    module ClassMethods
      # "Search.users" translates to "User.find" dynamically
      def method_missing(name, *args)
        # instantiate a new instance of self with
        # the @klass set to the missing method
        self.new(name.to_sym)
      end
    end
    
    module InstanceMethods
      def initialize(klass)
        @klass = klass
        
        # validate that the class derived from the missing method descends from
        # ActiveRecord and has been "configured" in `Setup.config { setup_tables {...} }'
        # (i.e. "Search.userz.with(...)" where "userz" is an invalid model)
        Validations.validate_class!(@klass)
      end
      
      # used to collect/parse the keywords that are to be searched, and return
      # the search results (hands off to the Rails finder)
      #
      # Example:
      #   Search.users.with("ryan heath")
      #   # => <#User ... > or []
      def with(keywords, options={})
        search_terms = keywords.match(/"(.+)"/) ? extract($1, :exact => true) : extract(keywords)
        return [] if search_terms.blank?
        
        klass = to_model(@klass)
        
        conditions = "(#{build_conditions_for(search_terms)})"
        conditions << " AND (#{options[:conditions]})" unless options[:conditions].blank?
        sanitized_sql_conditions = klass.send(:sanitize_sql_for_conditions, conditions)

        options = { :select => 'DISTINCT *', :conditions => sanitized_sql_conditions, :order => options[:order], :limit => options[:limit] }
        options.update :include => associations_to_include
        klass.find(:all, options)
      end
      
      private
        # constructs the conditions for the WHERE clause in the SQL statement.
        # (compares each search term against each configured column for that model)
        #
        # ultimately this allows for a single query rather than several small ones,
        # alleviating the need to open/close DB connections and instantiate multiple
        # ActiveRecord objects through the loop
        #
        # it should be noted that a search with too many keywords against too many columns
        # in a DB with too many rows will inevitably hurt performance (use ultrasphinx!)
        def build_conditions_for(terms)
          klass = to_model(@klass)
          
          returning([]) do |clause|
            Setup.table_settings[@klass].each do |column|
              # handle search associated objects
              if Hash === column
                column.each do |association, columns|
                  reflection = klass.reflect_on_association(association.to_sym)
                  next unless reflection
                  model = reflection.class_name.constantize
                  columns.each do |associated_column|
                    clause << build_conditions_for_terms_on_model(model, associated_column, terms)
                  end  
                end
              else
                clause << build_conditions_for_terms_on_model(klass, column, terms)
              end  
            end
          end.flatten.join(" OR ")
      	end
      	
      	def build_conditions_for_terms_on_model(klass, column, terms)
          terms.inject([]) do |clause, term|
            if klass.columns.map(&:name).include?(column.to_s)
              clause << "`#{klass.table_name}`.`#{column}` LIKE '%#{term}%'"
            end
          end
      	end
      	
      	def associations_to_include
        	includes = Setup.table_settings[@klass].collect do |e| 
        	  Hash === e ? e.keys : nil
        	end.compact || []
        end	
        
        # using scan(/\w+/) to parse the words
        #
        # emails were being separated (split on the "@" symbol since it's not a word) 
        # so "rheath@test.com" became ["rheath", "test.com"] as search terms, when we 
        # really want to keep emails intact. as a work around, the emails are pulled out before 
        # the words are scanned, then each email is pushed back into the array as its own criteria.
        #
        # TODO: refactor this method to be less complex for such a simple problem.
        def extract(terms, options={})
          return [terms] if options.delete(:exact)
          
          terms.gsub!("'", "")
          emails = strip_emails_from(terms)
          
          keywords = unless emails.blank?            
            emails.inject(terms.gsub(Regex.email, '').scan(/\w+/)) { |t, email| t << email }
          else
            terms.scan(/\w+/)
          end
          
          return (keywords.collect { |k| k.downcase } - Setup.dull_keywords.collect { |k| k.downcase })
      	end
             
        # extracts the emails from the keywords
        def strip_emails_from(text)
      	  text.split.reject { |t| t.match(Regex.email) == nil }
      	end
      	
      	# converts the symbol representation of a table to an actual ActiveRecord model
      	def to_model(klass)
      	  klass.to_s.singularize.classify.constantize
      	end
    end
  end
end