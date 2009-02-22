# Run preinitializer from geminstaller
require 'rubygems'
require 'geminstaller'

args = ''

# Specify --geminstaller-output=all and --rubygems-output=all for maximum debug logging
# args += ' --geminstaller-output=all --rubygems-output=all'

# The 'exceptions' flag determines whether errors encountered while running GemInstaller
# should raise exceptions (and abort Rails), or just return a nonzero return code
args += " --exceptions"

# This will use sudo by default on all non-windows platforms, but requires an entry in your
# sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
# See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
# Note that environment variables will NOT be passed via sudo!
# args += " --sudo" unless RUBY_PLATFORM =~ /mswin/

# The 'install' method will auto-install gems as specified by the args and config
# GemInstaller.install(args)

# The 'autogem' method will automatically add all gems in the GemInstaller config to your load path,
# using the rubygems 'gem' method.  Note that only the *first* version of any given gem will be loaded.
GemInstaller.autogem(args)
