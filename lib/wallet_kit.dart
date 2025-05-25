import 'package:flutter/services.dart';
import 'dart:io';

class WalletKit {
  static const MethodChannel _channel = MethodChannel('wallet_kit');

  static Future<void> addToAppleWallet(String pkpassUrl) async {
    if (!Platform.isIOS) {
      throw UnsupportedError("Apple Wallet is only supported on iOS.");
    }
    return _channel.invokeMethod('addToAppleWallet', pkpassUrl);
  }

  static Future<void> addToGoogleWallet(String jwtToken) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Google Wallet is only supported on Android.");
    }
    return _channel.invokeMethod('addToGoogleWallet', jwtToken);
  }
}
