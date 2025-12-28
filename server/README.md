# OBS Blade Standalone Server

This creates a standalone executable that serves the OBS Blade Flutter web app without requiring Flutter to be installed.

## Building the Standalone Executable

### Linux/macOS:
```bash
./build_standalone.sh
```

### Windows:
```cmd
build_standalone.bat
```

## What Gets Built

The build process creates a `dist` folder containing:
- **obs_blade_server** (or **obs_blade_server.exe** on Windows) - The standalone executable
- **web/** - The compiled Flutter web app files

## Running the Server

### Linux/macOS:
```bash
cd dist
./obs_blade_server [port]
```

### Windows:
```cmd
cd dist
obs_blade_server.exe [port]
```

The default port is **8080**. You can specify a different port:
```bash
./obs_blade_server 3000
```

Then open your browser to:
```
http://localhost:8080
```
(or whatever port you specified)

## Distribution

To distribute the app, simply copy the entire `dist` folder. Users only need to:
1. Run the executable
2. Open their browser to http://localhost:8080

**No Flutter or Dart installation required!**

## How It Works

1. `flutter build web` compiles the Flutter app to static HTML/JS/CSS files
2. `dart compile exe` compiles the Dart server to a native executable
3. The server executable uses the `shelf` package to serve the static files
4. The executable looks for the `web` folder in the same directory

## System Requirements

The compiled executable will only run on the platform it was built on:
- Build on Linux → runs on Linux
- Build on macOS → runs on macOS
- Build on Windows → runs on Windows

For cross-platform distribution, build the executable on each target platform.

## Advanced: Embedding Web Files

If you want a single-file executable (without needing the `web` folder), you'll need to use a resource bundler. Here are some options:

1. **resource_portable** package - Embeds files into the Dart executable
2. **shelf_static + base64** - Encode files as base64 strings in the code
3. **Build a custom bundler** - Read files during compile time and embed them

Let me know if you need help with single-file packaging!
