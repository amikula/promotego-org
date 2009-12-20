# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

ADMIN_EMAIL = "do-not-reply@promotego.org"

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Due to a strange dependency issue between geminstaller, geokit, and the
  # geokit-rails plugin, this is necessary to load geokit before geokit-rails
  # gets called.
  require 'geokit'

  config.action_controller.session = {
    :session_key => '_promote_go_session',
    :secret      => '79b62020b1e3a09609f4014cd4ad0b91ee4d2dafa9cd5057f8a952e70aaf4389da743f193c2aaac3b983939210720303d31b02ee2abc0b22b434b92568e6e05d'
  }
end

I18n.default_locale = :'en-US'

ENV['RECAPTCHA_PUBLIC_KEY'] = '6Ldu-AIAAAAAAG7LIohw_Gx3HoB7aWL3a_k9jNpS'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6Ldu-AIAAAAAALXrp6fSj3VOs6rk_FEln-ZTl33O'
