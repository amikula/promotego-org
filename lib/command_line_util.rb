require 'highline'

class CommandLineUtil
  class << self
    def create_user(role=nil)
      user = User.new
      [:login, :email, [:password, :password_confirmation]].each do |attrs|
        echo = attrs.to_s =~ /password/ ? '*' : true
        get_attributes_with_validation(user, attrs, echo)
      end

      user_saved = user.save
      if user_saved
        user.activate

        user.roles << Role.find_by_name(role.to_s)

        puts "User #{user.login} created with role #{role}"
      else
        puts "ERROR: Couldn't save user"
      end
    end

    def get_attributes_with_validation(model, attributes, echo=true)
      attributes = attributes.is_a?(Array) ? attributes : [attributes]

      attributes.each do |attribute|
        model.send("#{attribute}=", nil)
      end

      model.valid?

      nil_ok = true
      attributes.each do |attribute|
        nil_ok &&= model.errors[attribute].nil?
      end

      repeat = true
      while(repeat)
        attributes.each do |attribute|
          input_attribute(model, attribute, nil_ok, echo)
        end

        model.valid?
        repeat = attributes.inject(false){|val,att| val || (model.errors[att] != nil)}

        print_errors(model.errors, attributes) if repeat
      end
    end

    def print_errors(errors, attributes)
      puts
      attributes.each do |attribute|
        if errors[attribute]
          errors[attribute].each do |error|
            puts "#{attribute.to_s.capitalize} #{error}"
          end
        end
      end
      puts
    end

    def input_attribute(model, attribute, nil_ok=false, echo=true)
      nil_value_ok = nil_ok ? ' (Control-D for nil value)' : ''

      begin
        value = ask("Enter value for #{attribute}#{nil_value_ok}: ") {|q| q.echo = echo}
      rescue EOFError
        # Allow value to be nil if user hit Ctrl-D
      end

      print("\n") unless value
      model.send("#{attribute}=", value)
    end
  end
end
