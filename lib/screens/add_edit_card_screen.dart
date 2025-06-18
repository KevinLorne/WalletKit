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
  List<TextEditingController> _controllers = [];
  Color _selectedColor = Colors.blue;
  String _selectedTemplate = 'Custom';

  final _cardTemplates = {
    'Custom': <CardField>[],
    'Child': [
      CardField(label: 'School', value: '', icon: Icons.school),
      CardField(label: 'Teacher Name', value: '', icon: Icons.person),
      CardField(label: 'Doctor', value: '', icon: Icons.medical_services),
    ],
    'Elderly': [
      CardField(label: 'Age', value: '', icon: Icons.cake),
      CardField(label: 'Insurance', value: '', icon: Icons.health_and_safety),
      CardField(label: 'Allergies', value: '', icon: Icons.warning),
    ],
    'Medical': [
      CardField(label: 'Blood Type', value: '', icon: Icons.water_drop),
      CardField(label: 'Allergies', value: '', icon: Icons.warning),
      CardField(label: 'Primary Doctor', value: '', icon: Icons.local_hospital),
    ],
  };

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
    _buildControllers();
  }

  void _buildControllers() {
    _controllers =
        _fields.map((f) => TextEditingController(text: f.value)).toList();
  }

  void _saveCard() {
    // Sync controllers to field values
    for (int i = 0; i < _fields.length; i++) {
      _fields[i] = CardField(
        label: _fields[i].label,
        icon: _fields[i].icon,
        value: _controllers[i].text,
      );
    }

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
      setState(() {
        _fields.add(newField);
        _controllers.add(TextEditingController(text: newField.value));
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pinController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
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
          DropdownButtonFormField<String>(
            value: _selectedTemplate,
            decoration: const InputDecoration(labelText: 'Card Type'),
            items:
                _cardTemplates.keys.map((template) {
                  return DropdownMenuItem(
                    value: template,
                    child: Text(template),
                  );
                }).toList(),
            onChanged: (selected) {
              if (selected != null && selected != _selectedTemplate) {
                setState(() {
                  _selectedTemplate = selected;
                  _fields = List.from(_cardTemplates[selected]!);
                  _buildControllers();
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Text('Fields', style: theme.textTheme.titleMedium),
          ..._fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            final controller = _controllers[index];

            return ListTile(
              leading: field.icon != null ? Icon(field.icon) : null,
              title: Text(field.label),
              subtitle: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Enter value'),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _fields.removeAt(index);
                    _controllers[index].dispose();
                    _controllers.removeAt(index);
                  });
                },
              ),
            );
          }),
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
