#!/usr/bin/env ruby
# Ruby Example - Rails-style Application
# Testing: comments, strings, symbols, blocks, classes, modules

require 'time'
require 'json'

# Constants
API_VERSION = 'v1.0'
MAX_USERS = 1000
TIMEOUT = 30

# User class with ActiveRecord-style methods
class User
  attr_accessor :id, :name, :email, :age, :role
  attr_reader :created_at

  def initialize(name:, email:, age:, role: :user)
    @id = nil
    @name = name
    @email = email
    @age = age
    @role = role
    @created_at = Time.now
  end

  def adult?
    @age >= 18
  end

  def admin?
    @role == :admin
  end

  def to_h
    {
      id: @id,
      name: @name,
      email: @email,
      age: @age,
      role: @role,
      adult: adult?,
      created_at: @created_at.iso8601
    }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end

  def to_s
    "User{id=#{@id}, name='#{@name}', age=#{@age}}"
  end
end

# Repository module
module Repository
  class UserRepository
    def initialize
      @users = []
      @next_id = 1
    end

    def find(id)
      @users.find { |user| user.id == id }
    end

    def find_all
      @users.dup
    end

    def find_by_email(email)
      @users.find { |user| user.email == email }
    end

    def find_by_role(role)
      @users.select { |user| user.role == role }
    end

    def save(user)
      user.id = @next_id
      @next_id += 1
      @users << user
      user
    end

    def delete(id)
      @users.reject! { |user| user.id == id }
    end

    def count
      @users.length
    end

    def exists?(id)
      !find(id).nil?
    end
  end
end

# Service class with business logic
class UserService
  def initialize(repository)
    @repository = repository
  end

  def create_user(name:, email:, age:, role: :user)
    validate_age!(age)
    validate_email!(email)

    user = User.new(name: name, email: email, age: age, role: role)
    @repository.save(user)
  end

  def adult_users
    @repository.find_all.select(&:adult?)
  end

  def users_by_role(role)
    @repository.find_by_role(role)
  end

  def average_age
    users = @repository.find_all
    return 0.0 if users.empty?

    total_age = users.sum(&:age)
    total_age.to_f / users.length
  end

  def group_by_role
    @repository.find_all.group_by(&:role)
  end

  private

  def validate_age!(age)
    raise ArgumentError, 'Age must be between 0 and 150' unless age.between?(0, 150)
  end

  def validate_email!(email)
    raise ArgumentError, 'Invalid email format' unless email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end

# Enumerable demonstrations
def demonstrate_enumerables
  numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

  # Map
  doubled = numbers.map { |n| n * 2 }
  puts "Doubled: #{doubled.inspect}"

  # Select/Filter
  evens = numbers.select { |n| n.even? }
  puts "Evens: #{evens.inspect}"

  # Reduce
  sum = numbers.reduce(0) { |acc, n| acc + n }
  puts "Sum: #{sum}"

  # Chain methods
  result = numbers
    .select { |n| n.even? }
    .map { |n| n * 2 }
    .reduce(0, :+)
  puts "Chained result: #{result}"

  # Each with index
  numbers.each_with_index do |num, idx|
    puts "Index #{idx}: #{num}" if idx < 3
  end
end

# Hash operations
def demonstrate_hashes
  # Symbol keys
  config = {
    host: 'localhost',
    port: 3000,
    database: 'myapp',
    ssl: true
  }

  puts "\nHash demonstration:"
  puts "Host: #{config[:host]}"
  puts "Port: #{config[:port]}"

  # Merge
  extended = config.merge(timeout: 30, retries: 3)
  puts "Extended config keys: #{extended.keys.inspect}"

  # Transform
  uppercased = config.transform_keys { |k| k.to_s.upcase }
  puts "Uppercased keys: #{uppercased.keys.inspect}"

  # Each
  config.each do |key, value|
    puts "  #{key}: #{value}"
  end
end

# String operations
def demonstrate_strings
  text = "Hello, World!"

  puts "\nString demonstration:"
  puts "Length: #{text.length}"
  puts "Uppercase: #{text.upcase}"
  puts "Lowercase: #{text.downcase}"
  puts "Reversed: #{text.reverse}"
  puts "Contains 'World': #{text.include?('World')}"

  # String interpolation
  name = "Ruby"
  version = API_VERSION
  message = "Hello from #{name} version #{version}"
  puts message

  # Multiline strings
  multiline = <<~TEXT
    This is a multiline
    heredoc string that
    strips leading whitespace
  TEXT
  puts multiline

  # String methods
  email = "user@example.com"
  parts = email.split('@')
  puts "Email parts: #{parts.inspect}"
end

# Block demonstrations
def with_timing
  start_time = Time.now
  yield if block_given?
  end_time = Time.now
  puts "Execution time: #{((end_time - start_time) * 1000).round(2)}ms"
end

def demonstrate_blocks
  puts "\nBlock demonstration:"

  # Block with each
  [1, 2, 3].each { |n| puts "Number: #{n}" }

  # Block with times
  3.times { |i| puts "Iteration #{i}" }

  # Custom block usage
  with_timing do
    sleep 0.1
    puts "Task completed"
  end

  # Proc and Lambda
  square = proc { |x| x * x }
  double = ->(x) { x * 2 }

  puts "Square of 5: #{square.call(5)}"
  puts "Double of 5: #{double.call(5)}"
end

# Class with modules
module Timestampable
  attr_reader :created_at, :updated_at

  def touch_timestamps
    now = Time.now
    @created_at ||= now
    @updated_at = now
  end
end

class Post
  include Timestampable

  attr_accessor :title, :content, :author

  def initialize(title:, content:, author:)
    @title = title
    @content = content
    @author = author
    touch_timestamps
  end

  def summary(length = 100)
    content.length > length ? "#{content[0...length]}..." : content
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  puts "Ruby User Management System"
  puts "API Version: #{API_VERSION}"

  # Create repository and service
  repo = Repository::UserRepository.new
  service = UserService.new(repo)

  # Create users
  alice = service.create_user(
    name: 'Alice Johnson',
    email: 'alice@example.com',
    age: 28,
    role: :admin
  )
  bob = service.create_user(
    name: 'Bob Smith',
    email: 'bob@example.com',
    age: 17
  )
  charlie = service.create_user(
    name: 'Charlie Brown',
    email: 'charlie@example.com',
    age: 45
  )

  puts "\nCreated users:"
  [alice, bob, charlie].each { |user| puts "  #{user}" }

  # Query users
  adults = service.adult_users
  puts "\nAdult users: #{adults.length}"
  adults.each { |user| puts "  #{user.name} (#{user.age})" }

  # Average age
  avg_age = service.average_age
  puts "\nAverage age: #{avg_age.round(2)}"

  # Group by role
  grouped = service.group_by_role
  puts "\nUsers by role:"
  grouped.each do |role, users|
    puts "  #{role}: #{users.length}"
  end

  # Demonstrations
  demonstrate_enumerables
  demonstrate_hashes
  demonstrate_strings
  demonstrate_blocks

  # Create a post
  post = Post.new(
    title: 'Welcome to Ruby',
    content: 'Ruby is a dynamic, object-oriented programming language.',
    author: alice
  )
  puts "\nPost: #{post.title}"
  puts "Summary: #{post.summary(30)}"
  puts "Created at: #{post.created_at}"
end
