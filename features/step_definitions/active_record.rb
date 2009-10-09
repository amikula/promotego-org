Given /^there is a (\w+) like the following:$/ do |clazz, data|
  @object = clazz.constantize.new
  @object.attributes = Hash[data.rows_hash.map{|k,v| [k.underscore.tr(' ', '_'), v]}]
  @object.save!
end

Given /^that (\w+) is active$/ do |clazz|
  @object.should be_a(clazz.constantize)
  @object.activate
  @object.should be_active
end
