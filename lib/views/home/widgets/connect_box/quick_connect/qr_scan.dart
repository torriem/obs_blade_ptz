// Platform-specific implementation of QR scanner
// Mobile (iOS/Android) uses camera-based QR scanning
// Web shows a message that QR scanning is not available
export 'qr_scan_mobile.dart'
    if (dart.library.js_interop) 'qr_scan_web.dart';
