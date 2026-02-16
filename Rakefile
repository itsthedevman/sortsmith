# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "standard/rake"

task default: %i[test standard]

namespace :benchmark do
  desc "Run quick benchmark"
  task :quick do
    ruby "benchmark/quick_benchmark.rb"
  end

  desc "Run full benchmark suite"
  task :full do
    ruby "benchmark/sorting_benchmark.rb"
  end
end

desc "Run quick benchmark"
task benchmark: "benchmark:quick"
