#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "sortsmith"
require "benchmark/ips"

# Sample data generators
def generate_users(count)
  Array.new(count) do |i|
    {
      name: ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank"].sample,
      age: rand(18..65),
      score: rand(0..100),
      email: "user#{i}@example.com"
    }
  end
end

def generate_mixed_nil_users(count)
  Array.new(count) do |i|
    {
      name: i.even? ? ["Alice", "Bob", "Charlie"].sample : nil,
      age: rand(18..65),
      score: i.odd? ? rand(0..100) : nil
    }
  end
end

def generate_mixed_case_names(count)
  names = ["alice", "BOB", "Charlie", "DIANA", "eve", "Frank"]
  Array.new(count) { names.sample }
end

puts "=" * 80
puts "Sortsmith Performance Benchmarks"
puts "=" * 80
puts

# Benchmark 1: Basic hash key sorting
puts "Benchmark 1: Basic hash key sorting (1000 items)"
puts "-" * 80
users = generate_users(1000)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("native sort_by") do
    users.sort_by { |u| u[:name] }
  end

  x.report("sortsmith .dig") do
    users.sort_by.dig(:name).sort
  end

  x.report("sortsmith direct") do
    users.sort_by(:name).sort
  end

  x.compare!
end

puts "\n"

# Benchmark 2: Case-insensitive sorting
puts "Benchmark 2: Case-insensitive sorting (1000 items)"
puts "-" * 80
names = generate_mixed_case_names(1000)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("native downcase") do
    names.sort_by { |n| n.downcase }
  end

  x.report("sortsmith .insensitive") do
    names.sort_by.insensitive.sort
  end

  x.compare!
end

puts "\n"

# Benchmark 3: Descending order
puts "Benchmark 3: Descending order (1000 items)"
puts "-" * 80

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("native reverse") do
    users.sort_by { |u| u[:score] }.reverse
  end

  x.report("sortsmith .desc") do
    users.sort_by.dig(:score).desc.sort
  end

  x.report("sortsmith .reverse") do
    users.sort_by.dig(:score).reverse
  end

  x.compare!
end

puts "\n"

# Benchmark 4: Complex chaining
puts "Benchmark 4: Complex chaining - case-insensitive descending (1000 items)"
puts "-" * 80

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("native") do
    users.sort_by { |u| u[:name].to_s.downcase }.reverse
  end

  x.report("sortsmith") do
    users.sort_by.dig(:name).insensitive.desc.sort
  end

  x.compare!
end

puts "\n"

# Benchmark 5: Nil handling
puts "Benchmark 5: Nil handling (1000 items, ~50% nils)"
puts "-" * 80
mixed_users = generate_mixed_nil_users(1000)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("native with || fallback") do
    mixed_users.sort_by { |u| u[:name] || "" }
  end

  x.report("sortsmith nil_last (default)") do
    mixed_users.sort_by.dig(:name).sort
  end

  x.report("sortsmith nil_first") do
    mixed_users.sort_by.dig(:name).nil_first.sort
  end

  x.compare!
end

puts "\n"

# Benchmark 6: Small vs Large datasets
puts "Benchmark 6: Scaling - Small vs Large datasets"
puts "-" * 80

[10, 100, 1_000, 10_000].each do |size|
  puts "\n#{size} items:"
  data = generate_users(size)

  Benchmark.ips do |x|
    x.config(time: 3, warmup: 1)

    x.report("native") do
      data.sort_by { |u| u[:name] }
    end

    x.report("sortsmith") do
      data.sort_by.dig(:name).sort
    end

    x.compare!
  end
end

puts "\n"

# Benchmark 7: Delegated methods
puts "Benchmark 7: Delegated enumerable methods (1000 items)"
puts "-" * 80

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("native .first(3)") do
    users.sort_by { |u| u[:score] }.last(3).reverse
  end

  x.report("sortsmith .first(3)") do
    users.sort_by.dig(:score).desc.first(3)
  end

  x.report("native .each") do
    users.sort_by { |u| u[:name] }.each { |u| u[:name] }
  end

  x.report("sortsmith .each") do
    users.sort_by.dig(:name).each { |u| u[:name] }
  end

  x.compare!
end

puts "\n" + "=" * 60
