module RPH
  module EasySearch
    class Setup
      class << self
        # returns a hash with the keys as the models to be searched
        # and the values as arrays of columns for the respective model
        #
        # Example:
        #   $> Setup.settings
        #   $> => {"users"=>[:first_name, :last_name, :email], "projects"=>[:title, :description]}
        def table_settings
          @@table_settings ||= HashWithIndifferentAccess.new
        end
        
        # returns an array of keywords that serve as no benefit in a search
        #
        # Example:
        #   $> Setup.dull_keywords
        #   $> => ['a', 'and', 'but', 'the', ...]
        def dull_keywords
          (@@dull_keywords ||= Defaults.dull_keywords).flatten.uniq
        end
        
        # accepts a block that specifies the columns
        # to search for each model
        #
        # Example:
        #   Setup.config do
        #     setup_tables   { ... }
        #     strip_keywords { ... }
        #   end
        def config(&block)
          return nil unless block_given?
          self.class_eval(&block)
        end
        
        # REQUIRED
        # accepts a block that specifies the columns
        # to search for each model
        #
        # Example:
        #   setup_tables do
        #     users    :first_name, :last_name, :email
        #     projects :title, :description
        #   end
        def setup_tables(&block)
          return nil unless block_given?
          self.class_eval(&block)
          self.table_settings          
        end
        
        # OPTIONAL 
        # allows customization of the dull_keywords setting
        # (can be overwritten or appended)
        #
        # Example:
        #   DEFAULT_DULL_KEYWORDS = ['the', 'and', 'is']
        # 
        #  1) appending keywords to the default list
        #     strip_keywords do
        #       ['it', 'why', 'is']
        #     end
        #     # => ['the', 'and', 'it', 'why', 'is']
        #
        #  2) overwriting existing keywords
        #     strip_keywords(true) do
        #       ['something', 'whatever']
        #     end
        #     # => ['something', 'whatever']
        def strip_keywords(overwrite=false, &block)
          return nil unless block_given?
          raise(InvalidDullKeywordsType, InvalidDullKeywordsType.message) unless block.call.is_a?(Array)
          
          overwrite ? @@dull_keywords = block.call : @@dull_keywords = (self.dull_keywords << block.call)
          self.dull_keywords
        end
        
        # this is the magic that makes `setup_tables' work like it does.
        # once the block is eval'd those missing methods (i.e. "users" and "projects")
        # will be caught here and the table_settings hash will be updated with the
        # key set to the table, and the value set to the columns. this is what allows the
        # EasySearch plugin to work generically for any rails application.
        def method_missing(table, *columns)
          table_settings[table] = columns
        end
      end
    end
  end
end