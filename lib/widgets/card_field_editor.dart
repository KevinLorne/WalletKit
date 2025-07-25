import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardFieldEditor extends StatefulWidget {
  const CardFieldEditor({super.key});

  @override
  State<CardFieldEditor> createState() => _CardFieldEditorState();
}

class _CardFieldEditorState extends State<CardFieldEditor> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  IconData? _selectedIcon;

  final _quickIcons = <Map<String, dynamic>>[
    {'icon': Icons.person, 'label': 'Name'},
    {'icon': Icons.phone, 'label': 'Phone'},
    {'icon': Icons.email, 'label': 'Email'},
    {'icon': Icons.cake, 'label': 'Birthday'},
    {'icon': Icons.home, 'label': 'Address'},
    {'icon': Icons.favorite, 'label': 'Favorite'},
    {'icon': Icons.directions_car, 'label': 'Car'},
    {'icon': Icons.emergency, 'label': 'Emergency'},
    {'icon': null, 'label': 'Other'},
  ];

  void _selectQuickIcon(Map<String, dynamic> item) {
    if (item['icon'] == null) {
    } else {
      setState(() {
        _selectedIcon = item['icon'];
        _labelController.text = item['label'];
      });
    }
  }

  void _selectMoreIcon(Map<String, dynamic> item) {
    setState(() => _selectedIcon = item['icon']);
  }

  Widget _buildIconGrid(List<Map<String, dynamic>> icons, bool isMoreIcons) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          icons.map((item) {
            final icon = item['icon'] as IconData?;
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap:
                  () =>
                      isMoreIcons
                          ? _selectMoreIcon(item)
                          : _selectQuickIcon(item),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                      ),
                    ),

                    child:
                        icon != null
                            ? Icon(icon, size: 28)
                            : const Icon(Icons.more_horiz, size: 28),
                  ),

                  const SizedBox(height: 4),
                  Text(item['label'], style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Field'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Icons:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _buildIconGrid(_quickIcons, false),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'What kind of info is this?',
                  hintText: 'e.g. T-Shirt Size',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Enter the actual information',
                  hintText: 'e.g. Large',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final label = _labelController.text.trim();
            final value = _valueController.text.trim();
            if (label.isNotEmpty && value.isNotEmpty) {
              final field = CardField(
                label: label,
                value: value,
                icon: _selectedIcon,
              );
              Navigator.pop(context, field);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
