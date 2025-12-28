// Platform-specific implementation of PurchaseBase
// Mobile (iOS/Android) uses in-app purchases
// Web version has no in-app purchase functionality
export 'purchase_base_mobile.dart'
    if (dart.library.js_interop) 'purchase_base_web.dart';
