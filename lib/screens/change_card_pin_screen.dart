import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:walletkit/blocs/card_bloc.dart';
import 'package:walletkit/blocs/card_event.dart';
import '../models/card_model.dart';

class ChangeCardPinScreen extends StatefulWidget {
  final CardModel card;
  final VoidCallback? onPinUpdated;

  const ChangeCardPinScreen({super.key, required this.card, this.onPinUpdated});

  @override
  State<ChangeCardPinScreen> createState() => _ChangeCardPinScreenState();
}

class _ChangeCardPinScreenState extends State<ChangeCardPinScreen> {
  final _pinController = TextEditingController();

  void _saveNewPin() async {
    final newPin = _pinController.text.trim();
    if (newPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be at least 4 digits')),
      );
      return;
    }

    final updatedCard = widget.card.copyWith(pinCode: newPin);
    final box = Hive.box<CardModel>('cards');
    await box.put(updatedCard.id, updatedCard);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN updated')));
    context.read<CardBloc>().add(UpdateCardPin(widget.card.id, newPin));
    context.read<CardBloc>().add(LockCard(widget.card.id)); // re-lock

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change PIN for ${widget.card.title}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveNewPin,
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
