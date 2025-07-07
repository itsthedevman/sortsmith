# Sortsmith

[![Gem Version](https://badge.fury.io/rb/sortsmith.svg)](https://badge.fury.io/rb/sortsmith)
![Ruby Version](https://img.shields.io/badge/ruby-3.0+-ruby)
[![Tests](https://github.com/itsthedevman/sortsmith/actions/workflows/main.yml/badge.svg)](https://github.com/itsthedevman/sortsmith/actions/workflows/main.yml)

**Sortsmith** makes sorting Ruby collections feel natural and fun. Instead of wrestling with verbose blocks or complex comparisons, just chain together what you want in plain English.

```ruby
# Instead of this...
users.sort_by { |user| user[:name].downcase }.reverse

# Write this!
users.sort_by.dig(:name).downcase.reverse
```

Sortsmith extends Ruby's built-in `sort_by` method with a fluent, chainable API that handles the messy details so you can focus on expressing *what* you want sorted, not *how* to sort it.

## Table of Contents

- [Why Sortsmith?](#why-sortsmith)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Usage Examples](#usage-examples)
  - [Array Sorting](#array-sorting)
  - [Hash Collections](#hash-collections)
  - [Object Collections](#object-collections)
  - [Mixed Key Types](#mixed-key-types)
- [API Reference](#api-reference)
- [Migration from v0.2.x](#migration-from-v02x)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Why Sortsmith?

Ruby's `sort_by` is powerful, but real-world sorting often gets messy:

```ruby
# Sorting users by name, case-insensitive, descending
users.sort_by { |u| u[:name].to_s.downcase }.reverse

# What if some names are nil?
users.sort_by { |u| (u[:name] || "").downcase }.reverse

# What about mixed string/symbol keys?
users.sort_by { |u| (u[:name] || u["name"] || "").downcase }.reverse
```

Sortsmith handles all the edge cases and gives you a clean, readable API:

```ruby
users.sort_by.dig(:name, indifferent: true).insensitive.desc.sort
```

**Features:**
- **Fluent chaining** - Reads like English
- **Universal extraction** - Works with hashes, objects, and nested data
- **Indifferent key access** - Handles mixed symbol/string keys automatically
- **Nil-safe** - Graceful handling of missing data
- **Minimal overhead** - Extends existing Ruby methods without breaking compatibility
- **Tab-completable** - Discoverable API through your editor

## Installation

Add this line to your application's Gemfile:

```ruby
gem "sortsmith"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install sortsmith
```

## Quick Start

Sortsmith extends Ruby's `sort_by` method. When called without a block, it returns a chainable sorter:

```ruby
require "sortsmith"

# Basic string sorting
names = ["charlie", "Alice", "bob"]
names.sort_by.insensitive.sort
# => ["Alice", "bob", "charlie"]

# Hash sorting
users = [
  { name: "Charlie", age: 25 },
  { name: "Alice", age: 30 },
  { name: "Bob", age: 20 }
]

users.sort_by.dig(:name).sort
# => [{ name: "Alice", age: 30 }, { name: "Bob", age: 20 }, { name: "Charlie", age: 25 }]

# The original sort_by with blocks still works exactly the same!
users.sort_by { |u| u[:age] }
# => [{ name: "Bob", age: 20 }, { name: "Charlie", age: 25 }, { name: "Alice", age: 30 }]
```

## Core Concepts

Sortsmith uses a simple pipeline concept where each step is **optional** except for the terminator:

1. **Extract** - Get the value to sort by (`dig`) - *optional*
2. **Transform** - Modify the value for comparison (`downcase`, `upcase`) - *optional*
3. **Order** - Choose sort direction (`asc`, `desc`) - *optional*
4. **Execute** - Run the sort (`sort`, `sort!`, `reverse`) - **required**

```ruby
collection.sort_by.dig(:field).downcase.desc.sort
#          ↑       ↑           ↑        ↑    ↑
#          |    extract   transform  order execute
#       chainable  (opt)      (opt)   (opt) (required)
```

**Minimal example:**
```ruby
# This works! (though not particularly useful)
users.sort_by.sort  # Same as users.sort

# More practical examples
users.sort_by.dig(:name).sort           # Extract only
users.sort_by.downcase.sort             # Transform only
users.sort_by.desc.sort                 # Order only
users.sort_by.dig(:name).desc.sort      # Extract + order
```

Each step builds on the previous ones, so you can mix and match based on what your data needs. The only requirement is ending with a terminator to actually execute the sort.

## Usage Examples

### Array Sorting

```ruby
# Basic sorting
words = ["banana", "Apple", "cherry"]
words.sort_by.sort
# => ["Apple", "banana", "cherry"]

# Case-insensitive
words.sort_by.insensitive.sort
# => ["Apple", "banana", "cherry"]

# Descending order
words.sort_by.downcase.desc.sort
# => ["cherry", "banana", "Apple"]

# In-place mutation
words.sort_by.insensitive.sort!
# Modifies the original array
```

### Hash Collections

```ruby
users = [
  { name: "Charlie", score: 85, team: "red" },
  { name: "Alice", score: 92, team: "blue" },
  { name: "bob", score: 78, team: "red" }
]

# Sort by name (case-sensitive)
users.sort_by.dig(:name).sort
# => [{ name: "Alice" }, { name: "Charlie" }, { name: "bob" }]

# Sort by name (case-insensitive)
users.sort_by.dig(:name).insensitive.sort
# => [{ name: "Alice" }, { name: "bob" }, { name: "Charlie" }]

# Sort by score (descending)
users.sort_by.dig(:score).desc.sort
# => [{ score: 92 }, { score: 85 }, { score: 78 }]

# Multiple field extraction (nested digging)
data = [
  { user: { profile: { name: "Charlie" } } },
  { user: { profile: { name: "Alice" } } }
]

data.sort_by.dig(:user, :profile, :name).sort
# => [{ user: { profile: { name: "Alice" } } }, ...]
```

### Object Collections

```ruby
User = Struct.new(:name, :age, :city)

users = [
  User.new("Charlie", 25, "NYC"),
  User.new("Alice", 30, "LA"),
  User.new("bob", 20, "Chicago")
]

# Sort by any method/attribute
users.sort_by.dig(:name).insensitive.sort
# => [User.new("Alice"), User.new("bob"), User.new("Charlie")]

users.sort_by.dig(:age).reverse
# => [User.new("Alice", 30), User.new("Charlie", 25), User.new("bob", 20)]

# Works with any object that responds to the method
class Score
  def calculate; rand(100); end
end

scores = [Score.new, Score.new, Score.new]
scores.sort_by.dig(:calculate).desc.sort
```

### Mixed Key Types

Real-world data often has inconsistent key types. Sortsmith handles this gracefully:

```ruby
mixed_users = [
  { name: "Charlie" },        # symbol key
  { "name" => "Alice" },      # string key
  { :name => "Bob" },         # symbol key again
  { "name" => "Diana" }       # string key again
]

# The indifferent option handles both key types
mixed_users.sort_by.dig(:name, indifferent: true).sort
# => [{ "name" => "Alice" }, { :name => "Bob" }, { name: "Charlie" }, { "name" => "Diana" }]

# Without indifferent access, you'd get sorting failures or unexpected results
```

**Performance Note**: Indifferent key access adds modest overhead (~2x slower depending on the machine) but operates in microseconds and is typically worth the convenience for mixed-key scenarios.

```ruby
# Rails users can also normalize keys upfront for better performance
mixed_users.map(&:symbolize_keys).sort_by.dig(:name).sort

# But indifferent access is handy when you can't control the data source
api_response.sort_by.dig(:name, indifferent: true).sort
```

## API Reference

### Extractors

- **`dig(*identifiers, indifferent: false)`** - Extract values from hashes, objects, or nested structures
  - Works with hash keys, object methods, and nested paths
  - `indifferent: true` normalizes hash keys for consistent lookup across string/symbol keys

### Modifiers

- **`downcase`** - Convert extracted strings to lowercase for comparison
- **`upcase`** - Convert extracted strings to uppercase for comparison
- **`insensitive`** - Alias for `downcase` (semantic clarity)

### Ordering

- **`asc`** - Sort in ascending order (default)
- **`desc`** - Sort in descending order

### Terminators

- **`sort`** - Execute sort and return new array
- **`sort!`** - Execute sort and mutate original array
- **`to_a`** - Alias for `sort`
- **`reverse`** - Shorthand for `desc.sort`
- **`reverse!`** - Shorthand for `desc.sort!`

## Migration from v0.2.x

The v0.3.x API is more concise and intuitive:

```ruby
# v0.2.x (OLD - no longer works)
Sortsmith::Sorter.new(users).by_key(:name).case_insensitive.desc.sort

# v0.3.x (NEW)
users.sort_by.dig(:name).insensitive.desc.sort

# v0.2.x (OLD)
Sortsmith::Sorter.new(objects).by_method(:calculate_score).sort

# v0.3.x (NEW)
objects.sort_by.dig(:calculate_score).sort
```

**Key Changes:**
- `by_key` → `dig`
- `by_method`/`by_attribute` → `dig`
- `case_insensitive` → `insensitive` or `downcase`
- No more manual `Sorter.new()` - just call `sort_by` without a block

## Development

### Prerequisites

- Ruby 3.0+
- Nix with Direnv (optional, but recommended)

### Setting Up the Development Environment

With Nix:
```bash
direnv allow
```

Without Nix:
```bash
bundle install
```

### Running Tests

```bash
bundle exec rake test
```

### Code Style

This project uses StandardRB. To check your code:

```bash
bundle exec standardrb
```

To automatically fix issues:

```bash
bundle exec standardrb --fix
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Credits

- Author: Bryan "itsthedevman"

## Looking for a Software Engineer?

I'm currently looking for opportunities where I can tackle meaningful problems and help build reliable software while mentoring the next generation of developers. If you're looking for a senior engineer with full-stack Rails expertise and a passion for clean, maintainable code, let's talk!

[bryan@itsthedevman.com](mailto:bryan@itsthedevman.com)
