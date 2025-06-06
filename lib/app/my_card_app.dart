import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/card_bloc.dart';
import '../blocs/card_event.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';

class MyCardApp extends StatefulWidget {
  final bool showOnboarding;

  const MyCardApp({super.key, required this.showOnboarding});

  @override
  State<MyCardApp> createState() => _MyCardAppState();
}

class _MyCardAppState extends State<MyCardApp> with WidgetsBindingObserver {
  late bool _showOnboarding;
  late final CardBloc _cardBloc;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
    _cardBloc = CardBloc()..add(LoadCards());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _cardBloc.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _cardBloc.add(LockAllCards());
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cardBloc,
      child: MaterialApp(
        title: 'Card Manager',
        themeMode: ThemeMode.system,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home:
            _showOnboarding
                ? OnboardingScreen(onDone: _completeOnboarding)
                : const HomeScreen(),
      ),
    );
  }
}
