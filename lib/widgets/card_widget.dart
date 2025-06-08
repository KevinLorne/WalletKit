import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletkit/utils/pdf_exporter.dart';
import '../models/card_model.dart';
import '../blocs/card_bloc.dart';
import '../blocs/card_event.dart';
import '../screens/add_edit_card_screen.dart';

class CardWidget extends StatefulWidget {
  final CardModel card;

  const CardWidget({super.key, required this.card});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final ExpansionTileController _controller = ExpansionTileController();

  Future<void> _promptForPin(bool isAccessible) async {
    if (isAccessible) return;

    final enteredPin = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'PIN'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (enteredPin == widget.card.pinCode) {
      context.read<CardBloc>().add(UnlockCard(widget.card.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Card unlocked')));
    } else {
      // 🔒 Lock only this card and collapse it
      context.read<CardBloc>().add(LockCard(widget.card.id));
      _controller.collapse();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = context.select<CardBloc, bool>(
      (bloc) => bloc.state.unlockedCardIds.contains(widget.card.id),
    );
    final isAccessible = isUnlocked || widget.card.pinCode == null;

    return Opacity(
      opacity: isAccessible ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.card.color.withOpacity(0.9),
              widget.card.color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            controller: _controller,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
            onExpansionChanged: (expanded) {
              if (expanded && !isAccessible) {
                _promptForPin(false);
              }
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.card.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed:
                          isAccessible
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AddEditCardScreen(
                                          existingCard: widget.card,
                                        ),
                                  ),
                                );
                              }
                              : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed:
                          isAccessible
                              ? () => exportCardAsPdf(widget.card)
                              : null,
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed:
                          isAccessible
                              ? () {
                                context.read<CardBloc>().add(
                                  DeleteCard(widget.card.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Card deleted')),
                                );
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
            children:
                isAccessible
                    ? widget.card.fields.map((field) {
                      return ListTile(
                        dense: true,
                        leading:
                            field.icon != null
                                ? Icon(field.icon, color: Colors.white70)
                                : null,
                        title: Text(
                          field.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        subtitle: Text(
                          field.value,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      );
                    }).toList()
                    : [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Enter correct PIN to view card details.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
          ),
        ),
      ),
    );
  }
}
