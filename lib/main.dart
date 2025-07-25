import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/card_bloc.dart';
import 'blocs/card_event.dart';
import 'models/card_model.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CardFieldAdapter());
  Hive.registerAdapter(CardModelAdapter());
  await Hive.openBox<CardModel>('cards');

  final prefs = await SharedPreferences.getInstance();
  final onboardingSeen = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(showOnboarding: !onboardingSeen));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late bool _showOnboarding;
  late final CardBloc _cardBloc;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
    WidgetsBinding.instance.addObserver(this);
    _cardBloc = CardBloc()..add(LoadCards());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cardBloc.close();
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
        title: 'WalletKit',
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
