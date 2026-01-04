# Bech32 Elixir Library

## Overview
This is an Elixir implementation of BIP-0173 (Bech32 address format) for native v0-16 witness outputs. The library supports both Bitcoin and Nervos CKB addresses.

## Project Structure
```
lib/
  bech32.ex       - Main Bech32 implementation
test/
  bech32_test.exs - Test cases
  test_helper.exs - Test configuration
mix.exs           - Project configuration and dependencies
```

## Technology Stack
- **Language**: Elixir ~> 1.9
- **Package Manager**: Mix/Hex
- **Testing**: ExUnit

## Development Commands
- `mix deps.get` - Install dependencies
- `mix compile` - Compile the project
- `mix test` - Run all tests
- `mix docs` - Generate documentation (requires ex_doc)

## Dependencies
- `ex_doc` - Documentation generator (dev only)

## Notes
- This is a library package, not a web application
- The library has deprecation warnings for `^^^` operator (should use `Bitwise.bxor/2` instead)
- All 12 tests (10 doctests, 2 tests) pass successfully
