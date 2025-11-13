# Auto-reset blocked test users on server start

Rails.application.config.to_prepare do
  # Skip during asset precompilation or safe mode
  next if ENV['ZAMMAD_SAFE_MODE'] == '1'
  next if defined?(Rails::Console)

  # Only run in production and when database is ready
  next unless Rails.env.production?

  # Check if database is actually available
  begin
    next unless ActiveRecord::Base.connection.active?
    next unless ActiveRecord::Base.connection.table_exists?('users')
  rescue
    next
  end

  Rails.logger.info "========================================="
  Rails.logger.info "Checking test users status..."
  Rails.logger.info "========================================="

  # Reset login failures for test users
  test_users = [
    { email: 'prefeitura@suporte.com', password: 'PrefeituraSuporte123' },
    { email: 'suporte@cestas.com', password: 'AdminSuporte123' },
    { email: 'suportetecnico@email.com', password: nil, make_admin: true }
  ]

  test_users.each do |user_data|
    user = User.find_by(email: user_data[:email])

    if user
      Rails.logger.info "Found user: #{user_data[:email]}"
      Rails.logger.info "  - login_failed: #{user.login_failed}"
      Rails.logger.info "  - verified: #{user.verified}"
      Rails.logger.info "  - active: #{user.active}"

      # Always reset login failures and ensure verified/active
      user.update_columns(
        login_failed: 0,
        verified: true,
        active: true
      )

      # Handle password update if password is specified
      if user_data[:password].present?
        # Only update password if current hash doesn't verify
        # This prevents re-hashing on every startup
        password_valid = false
        begin
          password_valid = user.password.present? && PasswordHash.verified?(user.password, user_data[:password])
          Rails.logger.info "  - password verification: #{password_valid ? 'PASS' : 'FAIL'}"
        rescue => e
          Rails.logger.warn "  - password verification error: #{e.message}"
          password_valid = false
        end

        if !password_valid
          Rails.logger.info "  - updating password..."
          user.password = user_data[:password]
          user.password_confirmation = user_data[:password]
          user.save!
          Rails.logger.info "  ✓ Password updated"
        else
          Rails.logger.info "  ✓ Password already correct, skipping update"
        end
      end

      # Handle admin role assignment if requested
      if user_data[:make_admin]
        admin_role = Role.find_by(name: 'Admin')
        if admin_role && !user.roles.include?(admin_role)
          user.roles << admin_role
          Rails.logger.info "  ✓ Admin role added"
        elsif admin_role
          Rails.logger.info "  ✓ Already has admin role"
        else
          Rails.logger.warn "  ! Admin role not found in database"
        end
      end

      Rails.logger.info "  ✓ User ready for login"
    else
      Rails.logger.warn "User not found: #{user_data[:email]}"
    end
  rescue => e
    Rails.logger.error "Error resetting user #{user_data[:email]}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  Rails.logger.info "========================================="
end
