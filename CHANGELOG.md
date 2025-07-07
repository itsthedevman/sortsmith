# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Removed

## [0.9.0] - 12025-07-06

### 🎉 MAJOR REWRITE: Fluent Chainable API

**BREAKING CHANGES**: Complete API redesign introducing a fluent, chainable interface. See migration guide below.

**Pre-1.0 Notice**: This release represents our new stable API design, but we're seeking community feedback before locking in 1.0.0 compatibility guarantees.

### Added

#### Core API Transformation
- **Fluent API**: Direct extension of `Enumerable#sort_by` for natural Ruby integration
- **Chainable Interface**: Method chaining that reads like English: `users.sort_by.dig(:name).downcase.desc.sort`
- **Universal `dig` Method**: Single extraction method that works with hashes, objects, and nested structures
- **Indifferent Key Access**: Handle mixed symbol/string hash keys with `dig(:name, indifferent: true)`

#### New Extraction Methods
- `dig(*identifiers, indifferent: false)` - Extract values from hashes, objects, or nested structures
- Support for nested extraction: `dig(:user, :profile, :email)`
- Automatic fallback to method calls for non-hash objects

#### Enhanced Modifiers
- `downcase` / `upcase` - Case transformations with automatic type checking
- `insensitive` - Alias for `downcase` for semantic clarity
- `asc` / `desc` - Explicit sort direction control
- Smart modifier chaining that only affects compatible data types

#### Multiple Terminators
- `sort` - Returns new sorted array (non-mutating)
- `sort!` - Mutates original array in place
- `reverse` - Shorthand for `desc.sort`
- `reverse!` - Shorthand for `desc.sort!`
- `to_a` - Alias for `sort` for semantic clarity

#### Backward Compatibility
- `sort_by` with block maintains original Ruby behavior
- `sort_by` without block returns Sortsmith::Sorter instance
- Zero breaking changes for existing Ruby code

### Changed

#### API Design Philosophy
- **Before**: `Sortsmith::Sorter.new(collection).by_key(:name).case_insensitive.desc.sort`
- **After**: `collection.sort_by.dig(:name).insensitive.desc.sort`

#### Improved Ergonomics
- No more explicit `Sorter.new()` instantiation required
- Tab-completable method discovery
- Natural language flow in method chains
- Unified `dig` method replaces separate `by_key`/`by_method` methods

#### Enhanced Ruby Version Support
- **Restored Ruby 3.0 and 3.1 compatibility** - Previously removed in v0.2.0, now supported again
- Full compatibility matrix: Ruby 3.0.7, 3.1.7, 3.2.8, 3.3.8, 3.4.4
- Expanded from Ruby 3.2+ requirement back to Ruby 3.0+ for broader accessibility

### Removed

#### Legacy API (Breaking Changes)
- `by_key` method (replaced by `dig`)
- `by_method`/`by_attribute` methods (replaced by `dig`)
- `case_insensitive` method (replaced by `insensitive`/`downcase`)
- `Sortsmith::Step` class (internal restructure)
- Manual `Sorter.new()` instantiation requirement
- `rbs` and `steep` type checking

### Migration Guide

The new API is more concise and intuitive, but requires updating existing code:

```ruby
# v0.2.x (OLD)
Sortsmith::Sorter.new(users).by_key(:name).case_insensitive.desc.sort

# v0.9.x (NEW)
users.sort_by.dig(:name).insensitive.desc.sort

# v0.2.x (OLD)
Sortsmith::Sorter.new(objects).by_method(:calculate_score).sort

# v0.9.x (NEW)
objects.sort_by.dig(:calculate_score).sort
```

### Technical Improvements

- Complete test suite rewrite with comprehensive edge case coverage
- Enhanced error handling for mixed data types
- Improved performance through reduced object allocations
- Cleaner internal architecture with separation of concerns
- Better documentation with extensive API examples

## [0.2.0] - 12025-02-17

### Added

- Added Ruby version test matrix

### Changed

- Updated `flake.nix` to use Ruby 3.4

### Removed

- Removed Ruby 3.0 and 3.1 support

## [0.1.1] - 12025-01-15

### Changed
- Improved handling of non-string objects when sorting

## [0.1.0] - 12025-01-14

### Added
- Initial implementation of `Sortsmith::Sorter`
- Support for case-insensitive sorting
- Support for sorting by hash keys and object methods
- Ascending and descending sort directions
- Type checking with Steep/RBS
- GitHub Actions workflow for automated testing and type checking

[unreleased]: https://github.com/itsthedevman/sortsmith/compare/v0.9.0...HEAD
[0.9.0]: https://github.com/itsthedevman/sortsmith/compare/v0.2.0...v0.9.0
[0.2.0]: https://github.com/itsthedevman/sortsmith/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/itsthedevman/sortsmith/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/itsthedevman/sortsmith/compare/ac357965a1bc641d187333a5b032c5a423020ae9...v0.1.0
