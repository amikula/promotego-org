Given /^the following registers:$/ do |registers|
  Register.create!(registers.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) register$/ do |pos|
  visit registers_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following registers:$/ do |expected_registers_table|
  expected_registers_table.diff!(table_at('table').to_a)
end
