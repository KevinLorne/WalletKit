import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletkit/screens/onboarding_screen.dart';
import '../blocs/card_bloc.dart';
import '../blocs/card_state.dart';
import '../widgets/card_widget.dart';
import 'add_edit_card_screen.dart';
import 'select_card_for_pin_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? pinCode;

  const HomeScreen({super.key, this.pinCode});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Edit Card PIN',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SelectCardForPinEditScreen(),
                ),
              );
            },
          ),
        ],
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
