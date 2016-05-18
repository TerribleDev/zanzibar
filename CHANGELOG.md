# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.2.0] - 2016-05-18
### Changed
- Upgraded dependencies
    - `rubyntlm`: ~>0.4.0 to ~>0.6.0
    - `savon`: ~>2.10.0 to ~>2.11.0
    - `rubocop`: ~>0.28.0 to ~>0.39.0
- Lots of rubocop-y code cleanup
- Converted from code climate classic to code climate platform
- Added rake task to run code climate platform locally
- Broke low-level secret server operations into `zanzibar/client`

## [0.1.27] - 2016-04-15
### Added
- `zanzibar get` can fetch field values for fields other than password
    - This ability has not been added to Zanzifiles yet.

[0.2.0]: https://github.com/Cimpress-MCP/Zanzibar/compare/v0.1.27...v0.2.0
[Unreleased]: https://github.com/Cimpress-MCP/Zanzibar/compare/v0.2.0...HEAD
