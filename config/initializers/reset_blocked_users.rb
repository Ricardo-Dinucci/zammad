# Auto-reset blocked test users on server start

Rails.application.config.after_initialize do
  # Only run in production
  next unless Rails.env.production?

  # Reset login failures for test users
  test_users = [
    { email: 'prefeitura@suporte.com', password: 'PrefeituraSuporte123' },
    { email: 'suporte@cestas.com', password: 'AdminSuporte123' }
  ]

  test_users.each do |user_data|
    user = User.find_by(email: user_data[:email])
    next unless user

    # Reset login failures
    if user.login_failed > 0
      user.update_columns(
        login_failed: 0,
        verified: true,
        active: true
      )
      Rails.logger.info "Reset login failures for: #{user_data[:email]}"
    end
  rescue => e
    Rails.logger.error "Error resetting user #{user_data[:email]}: #{e.message}"
  end
end
