import 'open_checkout_stub.dart'
    if (dart.library.html) 'open_checkout_web.dart' as impl;

Future<bool> openCheckoutInBrowser(String url) =>
    impl.openCheckoutInBrowser(url);
