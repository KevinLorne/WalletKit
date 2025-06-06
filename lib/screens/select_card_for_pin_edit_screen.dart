import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/card_model.dart';
import 'change_card_pin_screen.dart'; // ✅ ADD THIS LINE

class SelectCardForPinEditScreen extends StatelessWidget {
  const SelectCardForPinEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<CardModel>('cards');
    final cards = box.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Change Card Pin')),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return ListTile(
            title: Text(card.title),
            subtitle: card.pinCode != null ? const Text("Has PIN") : null,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeCardPinScreen(card: card),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
