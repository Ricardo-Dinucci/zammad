# Disable max login failed attempts (allow unlimited login attempts)

Rails.application.config.to_prepare do
  # Override the max_login_failed check to always return false
  Auth::User.class_eval do
    private

    def max_login_failed?
      # Never block users for failed login attempts
      false
    end
  end
end
