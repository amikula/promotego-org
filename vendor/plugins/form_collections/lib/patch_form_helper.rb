require 'strscan'

#
# Hack FormHelper to render collections of objects in a more useful way
#
module ActionView::Helpers::FormHelper
  alias old_fields_for fields_for

  #
  # Hacked implementation of fields_for that accepts and renders an array of
  # objects.
  #
  #     <% fields_for(@post.comments) do |comment_form, comment| %>
  #       ...
  #     <% end %>
  #
  # Also accepts a String/Symbol indicating the prefix for each record:
  #
  #     <% fields_for(:suggestions, @post.comments) do |comment_form, comment| %>
  #       ...
  #     <% end %>
  #
  def fields_for(record, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.extract_options!

    prefix = nil
    if record.kind_of?(Symbol) || record.kind_of?(String)
      prefix = "#{record.to_s}"
      object = args.first
    else
      object = record
    end

    if object.kind_of?(Array)
      if !object.empty?
        if prefix.nil?
          prefix = ActionController::RecordIdentifier.plural_class_name(object.first)
        end
        builder = options[:builder] || ActionView::Base.default_form_builder
        object.each_with_index do |object, index|
          yield builder.new("#{prefix}[#{index}]", object, self, options, block), object
        end
      end
    else
      old_fields_for(record, *(args << options), &block)
    end
  end
end

