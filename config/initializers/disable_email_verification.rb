# Disable email verification requirement for login
# This allows users to login without email verification

Rails.application.config.to_prepare do
  Auth::Backend::Internal.class_eval do
    private

    def perform?
      # Remove email verification check - allow login even if not verified
      user.password.present?
    end
  end
end
