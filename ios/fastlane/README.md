fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios read_code_signing

```sh
[bundle exec] fastlane ios read_code_signing
```

Read and synchronize code signing assets

### ios create_app_id

```sh
[bundle exec] fastlane ios create_app_id
```

Create App ID on Apple Developer Portal

### ios nuke_match_assets

```sh
[bundle exec] fastlane ios nuke_match_assets
```

Nuke existing match assets (certificates and profiles)

### ios force_regenerate_profile

```sh
[bundle exec] fastlane ios force_regenerate_profile
```

Force regenerate provisioning profile

### ios release_ios_prod

```sh
[bundle exec] fastlane ios release_ios_prod
```

Release for Production iOS

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
