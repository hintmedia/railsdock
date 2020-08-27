# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- a bug that would cause migrations not to run in certain scenarios [I31](https://github.com/hintmedia/railsdock/issues/31) [PR32](https://github.com/hintmedia/railsdock/pull/32)
### Security

## [0.4.0] - 08-08-2020
### Changed
- default to exposing only necessary ports [PR26](https://github.com/hintmedia/railsdock/pull/26)
- move most config to compose file [PR28](https://github.com/hintmedia/railsdock/pull/28)
### Fixed
- handle new apps with no schema.rb or structure.sql [I22](https://github.com/hintmedia/railsdock/issues/22) [PR25](https://github.com/hintmedia/railsdock/pull/25)

## [0.3.1] - 07-20-2020
### Fixed
- command in docker-compose template [PR21](https://github.com/hintmedia/railsdock/pull/21)
### Added
- Initial Changelog