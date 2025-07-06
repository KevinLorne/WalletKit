import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../blocs/card_bloc.dart';
import '../blocs/card_event.dart';
import '../blocs/card_state.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';
import 'add_edit_card_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? pinCode;

  const HomeScreen({super.key, this.pinCode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPrompted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndPromptStarterCard();
  }

  Future<void> _checkAndPromptStarterCard() async {
    if (_hasPrompted) return;

    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('starter_card_prompt') ?? false;

    if (!shown && context.read<CardBloc>().state.cards.isEmpty) {
      _hasPrompted = true;

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Get Started'),
              content: const Text(
                'Would you like to start by creating a personal info card?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Maybe Later'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Let\'s Go'),
                ),
              ],
            ),
      );

      if (confirmed == true && context.mounted) {
        await prefs.setBool('starter_card_prompt', true);

        final starterCard = CardModel(
          id: const Uuid().v4(),
          title: 'My Personal Card',
          fields: [
            CardField(label: 'Name', value: '', icon: Icons.person),
            CardField(label: 'Age', value: '', icon: Icons.cake),
            CardField(
              label: 'Emergency Contact',
              value: '',
              icon: Icons.contact_phone,
            ),
            CardField(
              label: 'Insurance Name',
              value: '',
              icon: Icons.health_and_safety,
            ),
          ],
          colorValue: Colors.blue.value,
          isExpanded: false,
          pinCode: widget.pinCode, // ✅ Pass pinCode from widget
        );

        context.read<CardBloc>().add(AddCard(starterCard));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditCardScreen(existingCard: starterCard),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cards"),
        leading: IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'How it works',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        OnboardingScreen(onDone: () => Navigator.pop(context)),
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (context, state) {
          final visibleCards = state.cards;

          if (visibleCards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "No cards yet.\nTap the '+' button to add your first card.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: visibleCards.length,
            itemBuilder: (context, index) {
              final card = visibleCards[index];
              return CardWidget(card: card);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        tooltip: 'Add new card',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
