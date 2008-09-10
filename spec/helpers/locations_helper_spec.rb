require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsHelper do
  describe :phone_number_type_select do
    it "should render a select tag with the correct name" do
      helper.phone_number_type_select(nil, 0, 1).should have_tag("select[name=?]",
                                       "location[contacts][0][phone][1][type]")
    end

    it "should have all types" do
      helper.phone_number_type_select(nil, 0, 0).should have_tag('select') do
        LocationsHelper::PHONE_NUMBER_TYPES.each do |type|
          with_tag('option', type)
        end
      end
    end

    it "should only have the correct type selected" do
      option_tags = helper.phone_number_type_select('cell', 0, 0)

      option_tags.should have_tag('select') do
        with_tag('option[selected=selected]', 'cell')

        other_types = Array.new(LocationsHelper::PHONE_NUMBER_TYPES)
        other_types.delete('cell')

        other_types.each do |type|
          with_tag('option', type)
          without_tag('option[selected=selected]', type)
        end
      end
    end
  end
end
