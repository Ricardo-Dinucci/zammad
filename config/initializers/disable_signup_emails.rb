# Disable signup verification emails

Rails.application.config.to_prepare do
  # Skip during asset precompilation or safe mode
  next if ENV['ZAMMAD_SAFE_MODE'] == '1'
  next if defined?(Rails::Console)

  # Prevent NotificationFactory from sending signup/verification emails
  NotificationFactory.singleton_class.prepend(Module.new do
    def send(data)
      # Skip signup verification emails
      return if data[:template]&.include?('signup')
      return if data[:subject]&.match?(/verif|confirm/i)

      # Call original method for other emails
      super
    end
  end)
end
