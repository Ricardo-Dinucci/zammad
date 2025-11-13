# Auto-reset blocked test users on server start

Rails.application.config.to_prepare do
  # Only run in production and when database is ready
  next unless Rails.env.production?
  next unless ActiveRecord::Base.connection.table_exists?('users')

  Rails.logger.info "========================================="
  Rails.logger.info "Checking test users status..."
  Rails.logger.info "========================================="

  # Reset login failures for test users
  test_users = [
    { email: 'prefeitura@suporte.com', password: 'PrefeituraSuporte123' },
    { email: 'suporte@cestas.com', password: 'AdminSuporte123' }
  ]

  test_users.each do |user_data|
    user = User.find_by(email: user_data[:email])

    if user
      Rails.logger.info "Found user: #{user_data[:email]}"
      Rails.logger.info "  - login_failed: #{user.login_failed}"
      Rails.logger.info "  - verified: #{user.verified}"
      Rails.logger.info "  - active: #{user.active}"

      # Always reset and update to ensure clean state
      user.update_columns(
        login_failed: 0,
        verified: true,
        active: true
      )

      # Update password using the model to trigger Argon2 hashing
      user.password = user_data[:password]
      user.save(validate: false)

      Rails.logger.info "  ✓ User updated and ready for login"
    else
      Rails.logger.warn "User not found: #{user_data[:email]}"
    end
  rescue => e
    Rails.logger.error "Error resetting user #{user_data[:email]}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  Rails.logger.info "========================================="
end
