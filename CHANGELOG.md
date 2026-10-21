# Changelog

## [2.0.0](https://github.com/wasp-lang/mise-cabal/compare/v1.1.0...v2.0.0) (2026-10-21)


### ⚠ BREAKING CHANGES

* requires mise 2026.10.17 or newer.

### Features

* report version release dates from a shared Hackage index ([#21](https://github.com/wasp-lang/mise-cabal/issues/21)) ([53c30d2](https://github.com/wasp-lang/mise-cabal/commit/53c30d2f2dd9f8452cbfb20fabed3546f1136a9b)), closes [#20](https://github.com/wasp-lang/mise-cabal/issues/20)
* reuse the shared Hackage index when installing ([#22](https://github.com/wasp-lang/mise-cabal/issues/22)) ([1422b22](https://github.com/wasp-lang/mise-cabal/commit/1422b22a9087696afa4a802266ced3b907aedb5d))

## [1.1.0](https://github.com/wasp-lang/mise-cabal/compare/v1.0.0...v1.1.0) (2026-10-19)


### Features

* add Hackage package search ([#14](https://github.com/wasp-lang/mise-cabal/issues/14)) ([ed96d29](https://github.com/wasp-lang/mise-cabal/commit/ed96d2991a79f3bda92e63b5f7798050d1eb9455))
* log progress while installing ([#16](https://github.com/wasp-lang/mise-cabal/issues/16)) ([225593f](https://github.com/wasp-lang/mise-cabal/commit/225593f4813e50d5e4b95486d0eb8dae567d6627))


### Bug Fixes

* pass package name and version to cabal through env ([#12](https://github.com/wasp-lang/mise-cabal/issues/12)) ([b58df32](https://github.com/wasp-lang/mise-cabal/commit/b58df32be7dac77e098fdac9acd182936e42151a))
* show cabal build errors when install fails ([#13](https://github.com/wasp-lang/mise-cabal/issues/13)) ([b8a9dd1](https://github.com/wasp-lang/mise-cabal/commit/b8a9dd1368e7906fc40e4ccd444b5ea645c24894))
* show the cabal build log when an install fails ([#17](https://github.com/wasp-lang/mise-cabal/issues/17)) ([83044cd](https://github.com/wasp-lang/mise-cabal/commit/83044cdc4147c50b2fb2b91762d5b49677429667))

## [1.0.0](https://github.com/wasp-lang/mise-cabal/compare/v0.1.0...v1.0.0) (2026-10-19)


### Features

* implement Cabal backend plugin ([#1](https://github.com/wasp-lang/mise-cabal/issues/1)) ([2af6fb9](https://github.com/wasp-lang/mise-cabal/commit/2af6fb93b9a0d8e459d51217276dcea6bebb397b))


### Continuous Integration

* set up release-please ([7b81c64](https://github.com/wasp-lang/mise-cabal/commit/7b81c64252e8b8ba7ee8b3f459e690be1545839f))
