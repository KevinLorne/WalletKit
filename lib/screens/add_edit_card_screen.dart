import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:walletkit/blocs/card_event.dart';
import 'package:walletkit/widgets/card_field_editor.dart';

import '../blocs/card_bloc.dart';
import '../models/card_model.dart';

class AddEditCardScreen extends StatefulWidget {
  final CardModel? existingCard;

  const AddEditCardScreen({super.key, this.existingCard});

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _titleController = TextEditingController();
  final _pinController = TextEditingController();
  List<CardField> _fields = [];
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _titleController.text = widget.existingCard!.title;
      _fields = List.from(widget.existingCard!.fields);
      _selectedColor = widget.existingCard!.color;
      if (widget.existingCard!.pinCode != null) {
        _pinController.text = widget.existingCard!.pinCode!;
      }
    }
  }

  void _saveCard() {
    final newCard = CardModel(
      id: widget.existingCard?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      fields: _fields,
      isExpanded: false,
      colorValue: _selectedColor.value,
      pinCode:
          _pinController.text.trim().isNotEmpty
              ? _pinController.text.trim()
              : null,
    );

    final bloc = context.read<CardBloc>();
    if (widget.existingCard == null) {
      bloc.add(AddCard(newCard));
    } else {
      bloc.add(UpdateCard(newCard));
    }

    Navigator.pop(context);
  }

  void _addField() async {
    final newField = await showDialog<CardField>(
      context: context,
      builder: (context) => const CardFieldEditor(),
    );
    if (newField != null) {
      setState(() => _fields.add(newField));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCard == null ? 'Add Card' : 'Edit Card'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveCard),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Card Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pinController,
            decoration: const InputDecoration(
              labelText: 'PIN (optional)',
              hintText: 'Enter a PIN to lock this card',
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                Colors.primaries.take(6).map((color) {
                  return ChoiceChip(
                    label: const Text(''),
                    selected: _selectedColor == color,
                    selectedColor: color,
                    backgroundColor: color.withOpacity(0.4),
                    onSelected: (_) => setState(() => _selectedColor = color),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Fields', style: theme.textTheme.titleMedium),
          ..._fields.map(
            (field) => ListTile(
              title: Text(field.label),
              subtitle: Text(field.value),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _fields.remove(field)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: const Text('Add Field'),
          ),
        ],
      ),
    );
  }
}
