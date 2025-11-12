# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/
#
# Disable CSRF protection for simpler login

Rails.application.config.to_prepare do
  ApplicationController.class_eval do
    # Disable CSRF protection
    skip_before_action :verify_csrf_token, raise: false

    def verify_csrf_token
      # Override to do nothing
      true
    end
  end
end
