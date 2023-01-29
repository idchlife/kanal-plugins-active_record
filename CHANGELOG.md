## [Unreleased]

## [0.2.1] - 2023-01-29
- Fixed error about database not connected in the rake task for migrations. Connection was always NOT established, because how active record .establish_connection works. It is actually just adding connection to the pool, but not making any real connections.
## [0.1.0] - 2022-11-27

- Initial release
