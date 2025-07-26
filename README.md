# MCP Server for HealthKit and Health Connect Integration

## Introduction

The effective cross-platform integration with health platforms like HealthKit (iOS) and Health Connect (Android) presents technical challenges due to their inherent differences. The proposed MCP (Model-Context-Protocol) server seeks to solve this problem by creating a mobile application that functions as a server and exposes data through a minimalist, attractive, and easy-to-use interface from MCP-compatible clients, allowing health-related queries to be made simply and effectively.

## Objective

Create an MCP server that allows uniform access to health data collected from mobile devices and primarily smartwatches, enabling any MCP-compatible client to consume and perform queries on this health data.

## Main MCP Features

- **Unified Access:** Provides common methods to access various health metrics such as steps, calories, heart rate, sleep, among others.
- **Modularity:** Easily extensible for future metrics and additional data sources.
- **Cross-platform:** Implementation through Flutter for complete iOS and Android coverage.
- **Intuitive Interface:** Minimalist and attractive UI to facilitate configuration and monitoring.
- **Automatic Synchronization:** Continuous data updates from health devices.

## Use Cases

### 1. Continuous Health Monitoring
- Users who want to monitor their health metrics daily through smartwatch.
- Automatic updates on key metrics like steps taken, heart rate, and sleep quality.

### 2. Proactive Alerts
- Reception of notifications based on significant changes or specific events (e.g., heart rate spikes).

### 3. Automatic Data Synchronization
- Users who use multiple devices and want their data synchronized without manual intervention.

## Customer Personas

### Juan (34 years old)
- **Profession:** Systems Engineer.
- **Devices:** Uses a smartwatch daily and Android phone.
- **Interests:** Technology, preventive health, and self-monitoring.
- **Needs:** Juan seeks to query health data simply, using his preferred LLM to generate quick and specific queries about his personal metrics.

### Sofía (29 years old)
- **Profession:** Personal Trainer.
- **Devices:** iPhone and Apple Watch.
- **Interests:** Physical exercise, comprehensive performance monitoring of her clients.
- **Needs:** Needs a cross-platform solution that facilitates sharing information with clients, regardless of the type of device they use.

## Project Architecture

### Overview

The project is divided into two main sections:

- **UI (User Interface):** Contains all application screens for configuration and data visualization.
- **Core:** Contains models, data layer, and MCP server logic.

The design system is located in a package called [design_system][design_system].

### UI Section

[Flutter Bloc][bloc] is used for state management, specifically Cubit to manage screen state.
Each application section is organized in folders containing three components: the Screen (StatelessWidget for UI), the Cubit, and the state.

The `MainScreen` is the Widget that contains all screens and defines the `MaterialApp` along with the application router.

### Core Section

#### Health Platform Integration

- **HealthKit (iOS):** Native integration for health data access on Apple devices.
- **Health Connect (Android):** Integration with Google's API for health data on Android.
- **MCP Server:** Implementation of the MCP protocol to expose data in a unified way.

#### Data Models

Models are defined in the [models folder][models] and include:

- Physical activity metrics (steps, calories, distance)
- Vital data (heart rate, blood pressure)
- Sleep information (duration, quality, phases)
- Nutritional data
- Training metrics

#### Repositories and Data Sources

The repository pattern is used to manage the data layer.
A [repository][repository_folder] uses different [data sources][data_source_folder] (local cache, health APIs, MCP synchronization).

## Supported Health Metrics

### Physical Activity
- `STEPS` - Steps taken
- `ACTIVE_ENERGY_BURNED` - Active calories burned
- `TOTAL_CALORIES_BURNED` - Total calories burned
- `FLIGHTS_CLIMBED` - Floors climbed

### Vital Signs
- `HEART_RATE` - Heart rate
- `RESTING_HEART_RATE` - Resting heart rate
- `BLOOD_PRESSURE_SYSTOLIC` - Systolic blood pressure
- `BLOOD_PRESSURE_DIASTOLIC` - Diastolic blood pressure
- `BLOOD_OXYGEN` - Blood oxygen saturation
- `RESPIRATORY_RATE` - Respiratory rate

### Body Composition
- `WEIGHT` - Body weight
- `HEIGHT` - Height
- `BODY_MASS_INDEX` - Body mass index
- `BODY_FAT_PERCENTAGE` - Body fat percentage
- `LEAN_BODY_MASS` - Lean body mass

### Sleep
- `SLEEP_ASLEEP` - Time asleep
- `SLEEP_AWAKE` - Time awake
- `SLEEP_DEEP` - Deep sleep
- `SLEEP_LIGHT` - Light sleep
- `SLEEP_REM` - REM sleep

### Others
- `WATER` - Hydration
- `WORKOUT` - Workouts
- `NUTRITION` - Nutritional information
- `BLOOD_GLUCOSE` - Blood glucose
- `BODY_TEMPERATURE` - Body temperature

## Project Setup

### Environment Variables

Environment variables are defined in the `default.env` file located in the [`/environments/`](./environments) folder.
You can find more information about environment variables in the [README.md](./environments/README.md) file.

### Flavor Configuration

Project information is configured using [flavorizr], a Flutter utility to easily create flavors in your application.
To change it, go to the `flavorizr` section in the [pubspec] file.

Example to add a new flavor:

```yaml
flavorizr:
  flavors:
    development:
      app:
        name: "HealthMCP - Dev"
      android:
        applicationId: "com.healthmcp.dev"
      ios:
        bundleId: "com.healthmcp.dev"
    production:
      app:
        name: "HealthMCP"
      android:
        applicationId: "com.healthmcp.app"
      ios:
        bundleId: "com.healthmcp.app"
```

After making changes, run: `flutter pub run flutter_flavorizr`

### App Icons

Icons are generated using the [flutter_launcher_icons] plugin.
To change them, go to the `flutter_icons` section in the [pubspec] file.

After making changes, run: `flutter pub run flutter_launcher_icons:main`

### Splash Screen

The splash screen is generated using [flutter_native_splash].
To change it, go to the `flutter_native_splash` section in the [pubspec] file.

After making changes, run: `flutter pub run flutter_native_splash:create`

## Testing

### Mocks

For mocking, the project uses [mocktail][mocktail], a library inspired by [mockito][mockito] that eliminates the code generation part.

### Integration Tests

Integration tests for the project are defined in [integration_test][integration_test]. The Dart integration_test package is used for implementation.

### Code Generation

Code generation is created using the `build_runner` package.
To generate code, run the `clean_up.sh` script in the [scripts] folder or the following command:
`flutter pub run build_runner build --delete-conflicting-outputs`

## Pre-Push Configuration

To set up the pre-push hook, go to the project root and run:
`git config core.hooksPath .github/hooks`

## Contributing

This project follows Flutter development best practices and is designed to be easily extensible. Contributions are welcome following established code standards.

## License

[Specify project license]

[design_system]: ./design_system
[flavorizr]: https://pub.dev/packages/flutter_flavorizr
[flutter_launcher_icons]: https://pub.dev/packages/flutter_launcher_icons
[flutter_native_splash]: https://pub.dev/packages/flutter_native_splash
[pubspec]: ./pubspec.yaml
[bloc]: https://bloclibrary.dev
[models]: ./lib/core/model
[repository_folder]: ./lib/core/repository
[data_source_folder]: ./lib/core/source
[scripts]: ./scripts
[integration_test]: ./integration_test
[mocktail]: https://pub.dev/packages/mocktail
[mockito]: https://pub.dev/packages/mockito
