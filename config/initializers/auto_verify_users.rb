# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/
#
# Auto-verify users on creation - disables email verification requirement

Rails.application.config.to_prepare do
  User.class_eval do
    # Auto-verify users after creation
    after_create :auto_verify_user

    private

    def auto_verify_user
      # Skip if already verified or if it's a system user
      return if verified? || id == 1

      # Auto-verify the user
      update_column(:verified, true)

      Rails.logger.info { "Auto-verified user: #{login} (#{email})" }
    end
  end
end
