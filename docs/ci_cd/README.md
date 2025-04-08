# CI/CD and Versioning for MoveTopia

This documentation describes the CI/CD system and versioning process for the MoveTopia app.

## Versioning System

Our version numbers follow the format:

```
YYYY.MM.DD+HOTFIX
```

Example: `2025.04.03+0`

- **YYYY.MM.DD**: Date of the build
- **HOTFIX**: A number that is automatically incremented when multiple builds are created on the same day

## Repository Structure

The MoveTopia app follows a branch structure that supports continuous integration and delivery:

- **main**: The main branch for stable releases
  - Each merge to `main` triggers a complete release build
  - Creates APK and AAB
  - Automatically publishes on GitHub as a release (not pre-release)
  - Automatically deploys to the Google Play Store (internal track)

- **development**: Development branch for feature integration
  - Each merge to `development` triggers a release APK build
  - Creates only APK (no AAB)
  - Publishes on GitHub as a pre-release
  - No automatic deployment to Google Play Store

## Workflow Overview

### 1. Feature Development

1. Feature branches are branched from `development`
2. Development takes place in feature branches
3. Pull Requests are created to `development`
4. After successful CI check, PRs are merged into `development`
5. An automatic pre-release is created

### 2. Stable Release

1. When `development` is stable, a PR from `development` to `main` is created
2. After successful CI check, the PR is merged into `main`
3. Automatic release build is created (APK and AAB)
4. Complete GitHub release is created
5. AAB is automatically uploaded to the Google Play Store (internal track)

## GitHub Actions Workflows

The project uses GitHub Actions for automated builds and releases. The workflows are located in the `.github/workflows/` directory.

### Development Branch Release Workflow

File: `.github/workflows/build-dev-release.yml`

This workflow is automatically triggered:
- On every push to the `development` branch
- Manually via the GitHub interface

Features:
- Creates a release APK
- Uploads the build as an artifact
- Creates a GitHub pre-release with a tag in the format `YYYY.MM.DD+HOTFIX`
- Marks releases as "pre-release"

### Main Branch Release Workflow

File: `.github/workflows/build-android-release.yml`

This workflow is automatically triggered:
- On every push to the `main` branch
- Manually via the GitHub interface

Features:
- Creates a release APK and an App Bundle (AAB)
- Uploads the build as an artifact
- Creates a GitHub release with a tag in the format `YYYY.MM.DD+HOTFIX`
- Creates an official release (not marked as pre-release)
- Deploys the AAB to the Google Play Store (internal track)

### Debug Build Workflow

File: `.github/workflows/build-android-debug.yml`

This workflow is only triggered manually.

Features:
- Creates a debug APK
- Uploads the build as an artifact
- Does not create a GitHub release

### PR Check Workflow

File: `.github/workflows/pr-check.yml`

This workflow is automatically triggered:
- On Pull Requests to the branches `main` and `development`

Features:
- Performs a debug build to check buildability
- Can be skipped with the labels `docs-only` or `no-build`

## Fastlane

For build process automation, we use [Fastlane](https://fastlane.tools/). The configuration is located in the `android/fastlane` directory.

### Main Features of Fastlane

- **Automatic Version Generation**: Based on the current date and existing Git tags
- **Android Build Configuration**: Updates the `local.properties` file for the native Android build (not tracked by Git)
- **Flutter Version**: Generates a `version.dart` file with all version information for the app

### Available Lanes

- `build_debug`: Creates a debug build of the app
- `build_release`: Creates a release build of the app without deployment
- `build_debug_with_release`: Creates a debug build with complete version information
- `build_release_and_deploy`: Creates a release build with complete version information and deploys to the Google Play Store

## Manual Version Adjustment

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