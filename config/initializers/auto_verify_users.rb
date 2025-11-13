# Auto-verify all new users on creation (no email verification needed)

Rails.application.config.to_prepare do
  # Hook into User model to auto-verify on creation
  User.class_eval do
    before_create :auto_verify_user

    private

    def auto_verify_user
      # Auto-verify all new users
      self.verified = true unless verified

      # Ensure user is active
      self.active = true if active.nil?

      Rails.logger.info "Auto-verifying new user: #{email || login}"
    end
  end
end
