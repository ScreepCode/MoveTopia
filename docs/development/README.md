# Developer Documentation

This documentation provides information for developers working on the MoveTopia project.

## Project Structure

The MoveTopia project follows a Clean Architecture with clear layer separation:

```
lib/
├── core/                 # Core functionalities and base components  
├── data/                 # Data sources, repositories, and services
├── domain/               # Business logic, entities, and interfaces
├── presentation/         # UI components and ViewModels
│   ├── common/           # Common UI elements
│   ├── onboarding/       # Onboarding screens
│   ├── profile/          # Profile screens and settings
│   └── ...               # Additional feature-specific UI components
├── utils/                # Helper functions and utilities
├── l10n/                 # Localization files
├── generated/            # Generated files
├── main.dart             # Main entry point
└── version.dart          # Automatically generated version information
```

## Development Workflow

### Branch Strategy

1. Feature development takes place on separate branches that are branched from `development`
2. Naming convention: `feature/name-of-feature` or `bugfix/name-of-bug`
3. After completion, a Pull Request to `development` is created
4. After code review and successful CI check, it is merged into `development`
5. Stable versions are merged from `development` to `main`

### Local Development

1. Clone repository:
   ```bash
   git clone https://github.com/username/movetopia.git
   cd movetopia
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Build and run the app:
   ```bash
   flutter run
   ```

## Build Process

For detailed information on the build process and CI/CD system, see [CI/CD Documentation](../ci_cd/README.md).

## Code Guidelines

### Style Rules

- Follow the [Dart Style Guidelines](https://dart.dev/guides/language/effective-dart/style)
- Use camelCase for variables and functions
- Use PascalCase for classes and types
- Write code documentation in English
- Use `//` for single-line comments and `///` for documentation comments

### Architecture Guidelines

- Keep widgets as small and focused as possible
- Separate business logic from UI code
- Use Riverpod for state management
- Implement Repository pattern for data access
- Use Clean Architecture principles

### Error Handling

- Use try-catch blocks for error handling
- Log errors with meaningful messages
- Display user-friendly error messages

## Testing

### Unit Tests

Unit tests are located in the `test/` directory. Run tests with the following command:

```bash
flutter test
```

### Widget Tests

Widget tests test the user interface and interactions.

```bash
flutter test test/widget_tests/
```

### Integration Tests

Integration tests are located in the `integration_test/` directory.

```bash
flutter test integration_test/
```

## Internationalization

MoveTopia supports multiple languages. The translations are located in the `lib/l10n/` directory.

Add new strings to the `lib/l10n/app_en.arb` file and translations to the corresponding language files.

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/docs/introduction/getting_started)
- [Flutter Internationalization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization) 