module RPH
  module EasySearch
    require 'ostruct'
    
    # holds any regexp constants when dealing with search terms
    Regex = OpenStruct.new(
      :email => /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/
    )
    
    Defaults = OpenStruct.new(
      # these keywords will be removed from any search terms, as they
      # provide no value and just increase the size of the query.
      # (the idea is a small attempt to be as efficient as possible)
      :dull_keywords => ['a', 'the', 'and', 'or']
    )
  end
end