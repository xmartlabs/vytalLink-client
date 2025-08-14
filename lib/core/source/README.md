# Health MCP Server

A robust Flutter service that exposes health data through a Model Context Protocol (MCP) server interface.

## Features

- 🏥 **Health Data Integration**: Works with Apple HealthKit and Google Health Connect
- 🔒 **Permission Management**: Handles health permissions automatically
- 🛡️ **Error Handling**: Comprehensive error handling with custom exceptions
- ⚙️ **Configurable**: Easy configuration for different environments
- 📖 **Well Documented**: Full dartdoc documentation for all public APIs
- 🧪 **Testable**: Dependency injection for easy testing

## Usage

### Basic Setup

```dart
import 'package:your_app/core/source/mcp_server.dart';

// Create service with default configuration
final healthServer = HealthMcpServerService(
  config: HealthMcpServerConfig.development,
);

// Initialize the health client
await healthServer.initialize();

// Start the MCP server
final server = await healthServer.start();

print('MCP Server running on ${server.config.host}:${server.config.port}');
```

### Custom Configuration

```dart
final customConfig = HealthMcpServerConfig(
  serverName: 'my-health-server',
  serverVersion: '2.0.0',
  host: '0.0.0.0',
  port: 8080,
  endpoint: '/health-mcp',
  isJsonResponseEnabled: true,
);

final healthServer = HealthMcpServerService(config: customConfig);
```

### Testing with Mock Health Client

```dart
// For unit testing
final mockHealth = MockHealth();
final healthServer = HealthMcpServerService(
  config: HealthMcpServerConfig.development,
  healthClient: mockHealth,
);
```

### Stopping the Server

```dart
final wasStopped = await healthServer.stop();
if (wasStopped) {
  print('Server stopped successfully');
}
```

## Available Health Data Types

The server supports all Flutter Health plugin data types:

- `STEPS` - Step count
- `HEART_RATE` - Heart rate measurements  
- `BLOOD_PRESSURE` - Blood pressure readings
- `WEIGHT` - Weight measurements
- `HEIGHT` - Height measurements
- And many more...

## MCP Tool Interface

### get_health_data

Retrieves health data for specified parameters.

**Parameters:**
- `value_type` (string): Health data type (e.g., "STEPS", "HEART_RATE")
- `startTime` (string): ISO 8601 start time
- `endTime` (string): ISO 8601 end time

**Example Request:**
```json
{
  "value_type": "STEPS",
  "startTime": "2024-01-01T00:00:00Z",
  "endTime": "2024-01-02T00:00:00Z"
}
```

**Example Response:**
```
Health Data Retrieved Successfully

Total data points: 1
Time range: 2024-01-01T00:00:00.000Z to 2024-01-02T00:00:00.000Z
Type requested: STEPS

Data:
STEPS (1 data points):
  - Value: 8542 COUNT
    Date: 2024-01-01T00:00:00.000Z
    Source: Google Health Connect
```

## Error Handling

The service provides specific exceptions for different error scenarios:

- `HealthMcpServerException`: General server errors
- `HealthPermissionException`: Permission-related errors
- `HealthDataUnavailableException`: Health service availability errors

## Development

### Running the Example

1. Ensure Flutter Health plugin permissions are configured
2. For Android: Install Google Health Connect
3. For iOS: Configure HealthKit capabilities

### Code Quality

This codebase follows Dart/Flutter best practices:

- ✅ Comprehensive dartdoc documentation
- ✅ Proper error handling with custom exceptions
- ✅ Dependency injection for testability
- ✅ Single responsibility principle
- ✅ Immutable configuration objects
- ✅ Async/await best practices
- ✅ Proper resource cleanup

### Testing

```dart
// Example unit test
test('should start server successfully', () async {
  final mockHealth = MockHealth();
  final service = HealthMcpServerService(
    config: HealthMcpServerConfig.development,
    healthClient: mockHealth,
  );
  
  await service.initialize();
  final server = await service.start();
  
  expect(service.isRunning, isTrue);
  expect(server, isNotNull);
});
```

## License

MIT License - see LICENSE file for details.
