require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contactto/new" do
  before(:each) do
    params[:id] = "obfuscated"
    render '/contactto/new'
  end
  
  it "should have a form tag" do
    response.should have_tag('form[action=?]', '/contactto/send_mail') do
      with_tag('input[id=from]')
      with_tag('textarea[id=message]')
      with_tag('input[type=submit]')
      with_tag('input[type=hidden][name=email][value=obfuscated]')
    end
  end
end
