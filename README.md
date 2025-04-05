# MoveTopia

![MoveTopia App Icon](assets/icon/app_icon.png)

## CI/CD and Versioning

The MoveTopia project uses an automated CI/CD system with Fastlane and GitHub Actions for a consistent build and release pipeline.

### Versioning System

Our version numbers follow this format:

```
YYYY.MM.DD+HOTFIX
```

Example: `2025.04.03+0`

- **YYYY.MM.DD**: Date of the build
- **HOTFIX**: A number that is automatically incremented when multiple builds are created on the same day

### Fastlane

For build process automation, we use [Fastlane](https://fastlane.tools/). The configuration is located in the `android/fastlane` directory.

#### Main Features of Fastlane

- **Automatic Version Generation**: Based on the current date and existing Git tags
- **Android Build Configuration**: Updates the `local.properties` file for the native Android build (not tracked by Git)
- **Flutter Version**: Generates a `version.dart` file with all version information for the app

Details on the Fastlane configuration can be found in [android/fastlane/README.md](android/fastlane/README.md).

#### Available Lanes

- `build_debug`: Creates a debug build of the app
- `build_release`: Creates a release build of the app
- `build_debug_with_release`: Creates a debug build with complete version information
- `build_release_with_release`: Creates a release build with complete version information

### GitHub Actions

The project uses GitHub Actions for automated builds and releases. The workflows are located in the `.github/workflows/` directory.

#### Debug Build Workflow

File: `.github/workflows/build-android-debug.yml`

This workflow is automatically triggered:
- On every push to the `main` branch
- On pull requests to the `main` branch
- Manually through the GitHub interface

Features:
- Creates a debug APK
- Uploads the build as an artifact
- Creates a GitHub release with a tag in the format `YYYY.MM.DD+HOTFIX`
- Marks releases as "Pre-release"

#### Release Build Workflow

File: `.github/workflows/build-android-release.yml`

This workflow is only triggered manually and creates official releases.

Features:
- Creates a release APK
- Uploads the build as an artifact
- Creates a GitHub release with a tag in the format `YYYY.MM.DD+HOTFIX`
- Creates an official release (not marked as pre-release)

### Manual Version Adjustment

If you want to set a specific version for a build, you have the following options:

1. **Via local.properties**: 
   Edit the file `android/local.properties` and set:
   ```
   flutter.versionName=YOUR.VERSION.HERE.0
   flutter.versionCode=YOURCODENUMBER
   ```
   Note: This file is ignored by Git and won't be pushed to the repository.

2. **Via Environment Variables**:
   Set the following environment variables before running Fastlane:
   ```bash
   export VERSION_NAME="2025.04.03+1"
   export BUILD_NUMBER="2025040301"
   ```

3. **Directly in the GitHub Workflow**:
   You can manually define values for env.VERSION_NAME by customizing the workflow.

**Note**: After a manual version update, you should synchronize your local repository with the current changes.