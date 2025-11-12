#!/usr/bin/env ruby
# Temporary script to update passwords

user1 = User.find(4)
user1.password = 'AdminSuporte123'
user1.save!
puts "Updated user 4 (#{user1.email})"

user2 = User.find(8)
user2.password = 'PrefeituraSuporte123'
user2.save!
puts "Updated user 8 (#{user2.email})"

puts "Done!"
