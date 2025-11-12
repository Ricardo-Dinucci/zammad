#!/usr/bin/env ruby
# Script to make a user admin in Zammad
# Usage: bundle exec rails runner script/make_admin.rb email@example.com

email = ARGV[0] || ENV['USER_EMAIL']

if email.nil? || email.empty?
  puts "========================================="
  puts "ERROR: No email provided!"
  puts "========================================="
  puts "Usage: bundle exec rails runner script/make_admin.rb email@example.com"
  puts "Or set USER_EMAIL environment variable"
  exit 1
end

puts "========================================="
puts "Making user admin: #{email}"
puts "========================================="

begin
  user = User.find_by(email: email)

  if user.nil?
    puts "✗ User not found with email: #{email}"
    puts ""
    puts "Available users:"
    User.where.not(email: '').limit(10).each do |u|
      puts "  - #{u.email} (#{u.firstname} #{u.lastname})"
    end
    exit 1
  end

  admin_role = Role.find_by(name: 'Admin')
  agent_role = Role.find_by(name: 'Agent')

  user.roles = [admin_role, agent_role].compact
  user.save!

  puts "✓ User is now admin!"
  puts "========================================="
  puts "Email: #{user.email}"
  puts "Name: #{user.firstname} #{user.lastname}"
  puts "Roles: #{user.roles.map(&:name).join(', ')}"
  puts "========================================="

rescue => e
  puts "✗ Error: #{e.message}"
  exit 1
end
