fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android get_version_info

```sh
[bundle exec] fastlane android get_version_info
```



### android setup_keystore

```sh
[bundle exec] fastlane android setup_keystore
```

Setup keystore properties from CI environment

### android setup_github_token

```sh
[bundle exec] fastlane android setup_github_token
```



### android get_repo_config

```sh
[bundle exec] fastlane android get_repo_config
```



### android build_debug

```sh
[bundle exec] fastlane android build_debug
```

Build debug APK without creating a release or tag

### android build_debug_with_release

```sh
[bundle exec] fastlane android build_debug_with_release
```

Build debug APK with versioning

### android build_release

```sh
[bundle exec] fastlane android build_release
```

Build release APK without creating a release or tag

### android build_release_with_release

```sh
[bundle exec] fastlane android build_release_with_release
```

Build release APK with versioning

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
