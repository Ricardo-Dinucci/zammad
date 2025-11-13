# Disable max login failed attempts (allow unlimited login attempts)

Rails.application.config.to_prepare do
  # Skip during asset precompilation or safe mode
  next if ENV['ZAMMAD_SAFE_MODE'] == '1'
  next if defined?(Rails::Console)

  # Override the max_login_failed check to always return false
  Auth::User.class_eval do
    private

    def max_login_failed?
      # Never block users for failed login attempts
      false
    end
  end
end
