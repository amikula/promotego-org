require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/radius.html.erb" do
  include SearchHelper

  it 'should not display type selector when type parameter is present'
  it 'should select current type when type_id parameter is present'
end


