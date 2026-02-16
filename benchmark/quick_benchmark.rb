#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "sortsmith"
require "benchmark/ips"

# Quick comparison of common scenarios
puts "Quick Performance Comparison"
puts "=" * 60

users = Array.new(1000) do |i|
  {
    name: ["Alice", "bob", "Charlie", "DIANA"].sample,
    score: rand(0..100),
    age: i.even? ? rand(18..65) : nil
  }
end

puts "\n1. Basic sorting"
Benchmark.ips do |x|
  x.report("native") { users.sort_by { |u| u[:name] } }
  x.report("sortsmith") { users.sort_by.dig(:name).sort }
  x.compare!
end

puts "\n2. Case-insensitive + descending"
Benchmark.ips do |x|
  x.report("native") { users.sort_by { |u| u[:name].to_s.downcase }.reverse }
  x.report("sortsmith") { users.sort_by.dig(:name).insensitive.desc.sort }
  x.compare!
end

puts "\n3. With nil values"
Benchmark.ips do |x|
  x.report("native") { users.sort_by { |u| u[:age] || 0 } }
  x.report("sortsmith") { users.sort_by.dig(:age).sort }
  x.compare!
end

puts "\n4. Top 5 by score"
Benchmark.ips do |x|
  x.report("native") { users.sort_by { |u| u[:score] }.last(5).reverse }
  x.report("sortsmith") { users.sort_by.dig(:score).desc.first(5) }
  x.compare!
end

puts "\n" + "=" * 60
