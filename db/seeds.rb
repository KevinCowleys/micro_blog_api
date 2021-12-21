# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts 'Creating Admin Account...'

User.create(
  name: 'Admin',
  username: 'admin',
  birth_date: Faker::Time.between_dates(from: Date.today - 1000, to: Date.today, period: :all),
  email: 'admin@fake.com',
  bio: Faker::Games::WorldOfWarcraft.quote,
  location: Faker::Address.state,
  gender: %w[male female].sample,
  password_digest: BCrypt::Password.create('password')
)

puts 'Admin Account Created.'

puts 'Seeding Users...'

2000.times do
  User.create(
    name: Faker::Name.name,
    username: Faker::Internet.unique.username,
    birth_date: Faker::Time.between_dates(from: Date.today - 1000, to: Date.today, period: :all),
    email: Faker::Internet.unique.email,
    bio: Faker::Games::WorldOfWarcraft.quote,
    location: Faker::Address.state,
    gender: %w[male female].sample,
    password_digest: BCrypt::Password.create('password')
  )
end

puts 'Seeding Users done.'

puts 'Seeding Followers'

User.all.each do |user|
  follower = Follower.where(follower_id: user.id).first_or_initialize(
    following_id: 1
  )
  follower.save
  puts follower.inspect
end

puts 'Seeding Followers done.'

puts 'Seeding Posts...'

user_posts = User.find(User.pluck(:id).sample(30))

user_posts.each do |user_post|
  Post.create(
    user_id: user_post.id,
    content: Faker::TvShows::SiliconValley.quote,
  )
end

puts 'Seeding Posts done.'