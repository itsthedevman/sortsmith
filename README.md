# Sortsmith

[![Gem Version](https://badge.fury.io/rb/sortsmith.svg)](https://badge.fury.io/rb/sortsmith)
![Ruby Version](https://img.shields.io/badge/ruby-3.1+-ruby)
[![Tests](https://github.com/itsthedevman/sortsmith/actions/workflows/main.yml/badge.svg)](https://github.com/itsthedevman/sortsmith/actions/workflows/main.yml)

**Sortsmith** makes sorting Ruby collections feel natural and fun. Instead of wrestling with verbose blocks or complex comparisons, just chain together what you want in plain English.

```ruby
# Instead of this...
users.sort_by { |user| user[:name].downcase }.reverse

# Write this!
users.sort_by.dig(:name).downcase.reverse
```

Sortsmith extends Ruby's built-in `sort_by` method with a fluent, chainable API that handles the messy details so you can focus on expressing _what_ you want sorted, not _how_ to sort it.

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

Sortsmith extends Ruby's `sort_by` method with a fluent, chainable API. Use it with or without a block for maximum flexibility:

```ruby
require "sortsmith"

# Direct syntax for simple cases (NEW!)
names = ["charlie", "Alice", "bob"]
names.sort_by(:name).insensitive.sort
# => ["Alice", "bob", "charlie"]

# Or use the chainable API for complex scenarios
users = [
  { name: "Charlie", age: 25 },
  { name: "Alice", age: 30 },
  { name: "Bob", age: 20 }
]

users.sort_by.dig(:name).sort
# => [{ name: "Alice", age: 30 }, { name: "Bob", age: 20 }, { name: "Charlie", age: 25 }]

# Seamless integration with enumerable methods (NEW!)
users.sort_by(:age).desc.first(2)
# => [{ name: "Alice", age: 30 }, { name: "Charlie", age: 25 }]

# The original sort_by with blocks still works exactly the same!
users.sort_by { |u| u[:age] }
# => [{ name: "Bob", age: 20 }, { name: "Charlie", age: 25 }, { name: "Alice", age: 30 }]
```

## Core Concepts

Sortsmith uses a simple pipeline concept where each step is **optional** except for the terminator:

1. **Extract** - Get the value to sort by (`dig`, `method`, etc.) - _optional_
2. **Transform** - Modify the value for comparison (`downcase`, `upcase`, etc.) - _optional_
3. **Order** - Choose sort direction (`asc`, `desc`) - _optional_
4. **Execute** - Run the sort (`sort`, `sort!`, `reverse`, `to_a`, etc.) - **required**

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

### Simple Direct Syntax

```ruby
# Clean and direct for common operations
words = ["elephant", "cat", "butterfly"]
words.sort_by(:length).desc.sort
# => ["butterfly", "elephant", "cat"]

# Works great with hashes
users = [
  { name: "Cat", score: 99 },
  { name: "Charlie", score: 85 },
  { name: "karen", score: 50 },
  { name: "Alice", score: 92 },
  { name: "bob", score: 78 },
]

# Get top 3 by score
users.sort_by(:score).desc.first(3)
# => [{ name: "Cat", score: 99 }, { name: "Alice", score: 92 }, { name: "Charlie", score: 85 }]
```

### Object Method Sorting

```ruby
User = Struct.new(:name, :age, :city)

users = [
  User.new("Charlie", 25, "NYC"),
  User.new("Alice", 30, "LA"),
  User.new("bob", 20, "Chicago")
]

# Sort by any method or attribute
users.sort_by.method(:name).insensitive.sort
# => [User.new("Alice"), User.new("bob"), User.new("Charlie")]

# Or use the semantic alias
users.sort_by.attribute(:age).desc.first
# => User.new("Alice", 30, "LA")

# Methods with arguments work too
class Product
  def price_in(currency)
    # calculation logic
  end
end

products.sort_by.method(:price_in, "USD").sort
```

### Hash Collections with Multiple Access Patterns

```ruby
users = [
  { name: "Charlie", score: 85, team: "red" },
  { name: "Alice", score: 92, team: "blue" },
  { name: "bob", score: 78, team: "red" }
]

# Multiple semantic ways to express extraction
users.sort_by.key(:name).insensitive.sort      # Emphasizes hash keys
users.sort_by.field(:score).desc.sort          # Emphasizes data fields
users.sort_by.dig(:team, :name).sort           # Nested access

# Case handling with explicit naming
users.sort_by(:name).case_insensitive.reverse
# => [{ name: "bob" }, { name: "Charlie" }, { name: "Alice" }]
```

### Seamless Enumerable Integration

```ruby
# Chain directly into enumerable methods - no .to_a needed!
users.sort_by(:score).desc.first(2)           # Top 2 performers
users.sort_by(:name).each { |u| puts u }      # Iterate in order
users.sort_by(:team).map(&:name)              # Transform sorted results
users.sort_by(:score).select { |u| u[:active] } # Filter sorted results

# Array access works too
users.sort_by(:score).desc[0]                 # Best performer
users.sort_by(:name)[1..3]                    # Users 2-4 alphabetically

# Quick stats
users.sort_by(:score).count                   # Total count
users.sort_by(:team).count { |u| u[:active] } # Conditional count
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

### Universal Extraction

- **`sort_by(field, **opts)`\*\* - Direct field extraction (NEW!)
  - Works with hashes, objects, and any method name
  - Supports all the same options as `dig` and `method`

### Extractors

- **`dig(*identifiers, indifferent: false)`** - Extract values from hashes, objects, or nested structures
- **`method(method_name, \*args, **kwargs)`\*\* - Call methods on objects with arguments (NEW!)
- **`key(\*identifiers, **opts)`** - Alias for `dig` (semantic clarity for hash keys) (NEW!)
- **`field(\*identifiers, **opts)`** - Alias for `dig` (semantic clarity for object fields) (NEW!)
- **`attribute(method_name, \*args, **kwargs)`** - Alias for `method` (semantic clarity) (NEW!)

### Modifiers

- **`downcase`** - Convert extracted strings to lowercase for comparison
- **`upcase`** - Convert extracted strings to uppercase for comparison
- **`insensitive`** - Alias for `downcase` (semantic clarity)
- **`case_insensitive`** - Alias for `downcase` (explicit case handling) (NEW!)

### Ordering

- **`asc`** - Sort in ascending order (default)
- **`desc`** - Sort in descending order

### Terminators

- **`sort`** - Execute sort and return new array
- **`sort!`** - Execute sort and mutate original array
- **`to_a`** - Alias for `sort`
- **`to_a!`** - Alias for `sort!` (NEW!)
- **`reverse`** - Shorthand for `desc.sort`
- **`reverse!`** - Shorthand for `desc.sort!`

### Delegated Enumerable Methods (NEW!)

The following methods execute the sort and delegate to the resulting array:

- **`first(n=1)`**, **`last(n=1)`** - Get first/last n elements
- **`take(n)`**, **`drop(n)`** - Take/drop n elements
- **`each`**, **`map`**, **`select`** - Standard enumerable operations
- **`[](index)`** - Array access by index or range
- **`size`**, **`count`**, **`length`** - Size information

```ruby
# All of these execute the sort first, then apply the operation
users.sort_by(:score).desc.first(3)    # Get top 3
users.sort_by(:name).take(5)           # Take first 5 alphabetically
users.sort_by(:team)[0]                # First by team name
users.sort_by(:score).size             # Total size after sorting
```

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
