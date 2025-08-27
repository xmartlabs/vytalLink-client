# Local Health Data Server – Flutter + MCP

This project allows you to bring your personal health metrics to life inside any MCP-compatible AI client — such as Claude, Cursor, or local LLMs.

It runs entirely on your phone (Android or iOS) using Flutter, connects to Apple HealthKit or Google Health Connect, and serves your data through an MCP server so AI models can query it in a structured, machine-readable format.

## What’s inside

- health — Reads health data cross-platform (HealthKit on iOS, Health Connect on Android).
- mcp_server — Spins up an HTTP MCP server and registers tools.
- flutter_bloc + freezed — State and models for the Home screen.
- auto_route — Simple navigation.
- network_info_plus + wakelock_plus — Show device IP and keep the device awake while serving.
- intl — Localized UI.

## How it works

The core is `HealthMcpServerService` `(lib/core/source/mcp_server.dart)`, which starts an on-device MCP HTTP server and registers one tool:

- Tool name: `get_health_data`
- Inputs: `{ type: string, start: ISO8601 string, end: ISO8601 string }`
- Behavior: checks permissions, reads data via the `health` package, returns JSON.

Example args:
- type: `STEPS`
- start: `2025-01-01T00:00:00Z`
- end: `2025-01-02T00:00:00Z`

## Run it

1) Requirements
- Flutter 3.32+
- A physical device is best (emulators often lack Health data)
- Android: Install “Health Connect by Android” from Play Store

2) Install dependencies
```bash
fvm flutter pub get
```

3) Launch the app
```bash
fvm flutter run
```

4) Start the MCP server
- In the Home screen, tap Start. The app shows the device IP, port, and endpoint (e.g., `http://<ip>:<port>/<endpoint>`).

5) Connect from Cursor (example)
- Add an MCP HTTP provider using the URL shown in the app, e.g. `http://192.168.1.10:8080/mcp`.
- Invoke `get_health_data` with args like:
	- type: `STEPS`
	- start: `2025-01-01T00:00:00Z`
	- end: `2025-01-02T00:00:00Z`

### Cursor MCP config example

Add this to your MCP config in Cursor (replace the URL with your device’s IP/port/endpoint):

```json
{
	"mcpServers": {
		"MCP Mobile": {
			"type": "streamable-http",
			"url": "http://192.168.1.1:8080/mcp",
			"note": "For Streamable HTTP connections, add this URL directly in your MCP Client"
		}
	}
}
```

## Using the MCP service in code

The service is wired in `HomeCubit` (`lib/ui/home/home_cubit.dart`). Flow:
- Build a config (host/IP, port, endpoint)
- `start()` boots the MCP server and registers tools
- `stop()` shuts it down

Contract (simplified):
- Input: `{ type, start, end }`
- Output: `{ ok: boolean, data?: any, error?: { message, code? } }`

## Navigation

AutoRoute points to a Home screen that shows server status, IP/endpoint, and Start/Stop controls.

## Permissions to grant

iOS (HealthKit):
- First read prompts for Health permissions. Allow the requested types.

Android (Health Connect):
- Install the Health Connect app
- In Health Connect, connect your data sources (Fitbit/Google Fit/etc.)
- Grant this app read permissions when prompted
- Ensure your sources are syncing into Health Connect

General:
- Network permission and Health scopes are declared in the manifest, but you still must accept runtime prompts. If results are empty, check that the type is supported and the time range has data.

## Where things live

- `lib/core/source/mcp_server.dart` — HealthMcpServerService + tool definition
- `lib/ui/home/` — Screen and cubit that control the server
- `android/app/src/main/AndroidManifest.xml` — Permissions (including ACCESS_NETWORK_STATE and Health Connect)

Made with ❤️ by Xmartlabs.

## Contribute
👉 If you want to contribute please feel free to submit pull requests.

👉 If you have a feature request please open an issue.

👉 If you found a bug or need help please let us know.

👉 If you enjoy using SimonAI we would love to hear about it! Drop us a line on X.

## License
```
Copyright (c) 2025 Xmartlabs SRL

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```