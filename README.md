# Sortsmith

[![Gem Version](https://badge.fury.io/rb/sortsmith.svg)](https://badge.fury.io/rb/sortsmith)
![Ruby Version](https://img.shields.io/badge/ruby-3.3.7-ruby)
[![Tests](https://github.com/itsthedevman/sortsmith/actions/workflows/main.yml/badge.svg)](https://github.com/itsthedevman/sortsmith/actions/workflows/main.yml)

Sortsmith is a flexible sorting library for Ruby that makes complex sorting operations simple and composable. It makes handling common sorting patterns like case-insensitive sorting of hashes and objects easy, while remaining extensible for custom sorting needs.

## Looking for a Software Engineer?

I'm currently looking for opportunities where I can tackle meaningful problems and help build reliable software while mentoring the next generation of developers. If you're looking for a senior engineer with full-stack Rails expertise and a passion for clean, maintainable code, let's talk!

[bryan@itsthedevman.com](mailto:bryan@itsthedevman.com)

## Table of Contents

- [Compatibility](#compatibility)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Sorting](#basic-sorting)
  - [Hash Sorting](#hash-sorting)
  - [Object Sorting](#object-sorting)
  - [Case Insensitive Sorting](#case-insensitive-sorting)
  - [Reverse Sorting](#reverse-sorting)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Changelog](#changelog)
- [Credits](#credits)

Also see: [API Documentation](https://itsthedevman.com/docs/sortsmith)

## Compatibility

Currently tested on:
- MRI Ruby 3.2+
- NixOS (see `flake.nix` for details)

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

## Usage

### Basic Sorting

```ruby
# Sort an array of Strings
users = ["Bob", "Alice", "Carol"]

sorted_users = Sortsmith::Sorter.new(users).sort

# Result: ["Alice", "Bob", "Carol"]
```

### Hash Sorting

```ruby
# Sort an array of hashes by a key
users = [
  { name: "Carol", age: 35 },
  { name: "Bob", age: 25 },
  { name: "Alice", age: 30 }
]

sorted_users = Sortsmith::Sorter.new(users)
  .by_key(:name)
  .sort

# Result: [{ name: "Alice" }, { name: "Bob" }, { name: "Carol" }]
```

### Object Sorting

```ruby
# Sort objects by method/attribute
class User < Data.define(:name)
end

users = [User.new(name: "Bob"), User.new(name: "Carol"), User.new(name: "Alice")]

sorted_users = Sortsmith::Sorter.new(users)
  .by_method(:name)
  .sort

# Result: [#<data User name="Alice">, #<data User name="Bob">, #<data User name="Carol">]
```

### Case Insensitive Sorting

```ruby
users = [
  {"name" => "bob"},
  {"name" => "Billy"},
  {"name" => "Alice"},
  {"name" => "carol"},
  {"name" => "Cassidy"},
  {"name" => "alex"}
]

# Order of methods does not matter
# However, the hash's key type does
sorted_users = Sortsmith::Sorter.new(users)
    .case_insensitive
    .by_key("name")
    .sort

# Result: [{"name"=>"Alice"}, {"name"=>"alex"}, {"name"=>"Billy"}, {"name"=>"bob"}, {"name"=>"Cassidy"}, {"name"=>"carol"}]
```

### Reverse Sorting

```ruby
# Sort in descending order
sorted_desc = Sortsmith::Sorter.new(array)
  .by_attribute(:name)
  .desc
  .sort
```

## Development

### Prerequisites

- Ruby 3.3.6
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

### Type Checking

```bash
bundle exec steep check
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

The gem is available as open source under the terms of the [MIT License](LICENSE.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Credits

- Author: Bryan "itsthedevman"
