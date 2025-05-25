import 'package:flutter/material.dart';
import 'dart:io';

import 'package:walletkit/wallet_kit.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Kit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  void _addToAppleWallet(BuildContext context) async {
    if (!Platform.isIOS) {
      _showMessage(context, 'Apple Wallet is only available on iOS.');
      return;
    }

    try {
      const pkpassUrl = 'https://example.com/sample.pkpass';
      await WalletKit.addToAppleWallet(pkpassUrl);
    } catch (e) {
      _showMessage(context, 'Failed to add to Apple Wallet.\n$e');
    }
  }

  void _addToGoogleWallet(BuildContext context) async {
    if (!Platform.isAndroid) {
      _showMessage(context, 'Google Wallet is only available on Android.');
      return;
    }

    try {
      const jwtToken = 'REPLACE_WITH_REAL_JWT_TOKEN';
      await WalletKit.addToGoogleWallet(jwtToken);
    } catch (e) {
      _showMessage(context, 'Failed to add to Google Wallet.\n$e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _addToAppleWallet(context),
              icon: const Icon(Icons.apple),
              label: const Text("Add to Apple Wallet"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _addToGoogleWallet(context),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text("Add to Google Wallet"),
            ),
          ],
        ),
      ),

    );
  }
}
