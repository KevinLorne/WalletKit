import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'card_model.g.dart';

@HiveType(typeId: 1)
class CardField {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final String value;

  @HiveField(2)
  final int? iconCode;

  CardField({required this.label, required this.value, IconData? icon})
    : iconCode = icon?.codePoint;

  IconData? get icon =>
      iconCode != null
          ? IconData(iconCode!, fontFamily: 'MaterialIcons')
          : null;
}

@HiveType(typeId: 2)
class CardModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<CardField> fields;

  @HiveField(3)
  final bool isExpanded;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final String? pinCode;

  CardModel({
    required this.id,
    required this.title,
    required this.fields,
    this.isExpanded = false,
    required this.colorValue,
    this.pinCode,
  });

  /// Convenience constructor for UI usage with Color
  CardModel.withColor({
    required String id,
    required String title,
    required List<CardField> fields,
    bool isExpanded = false,
    required Color color,
    this.pinCode,
  }) : this.id = id,
       this.title = title,
       this.fields = fields,
       this.isExpanded = isExpanded,
       this.colorValue = color.value;

  Color get color => Color(colorValue);

  CardModel copyWith({
    String? id,
    String? title,
    List<CardField>? fields,
    bool? isExpanded,
    Color? color,
    String? pinCode,
  }) {
    return CardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fields: fields ?? this.fields,
      isExpanded: isExpanded ?? this.isExpanded,
      colorValue: color?.value ?? this.colorValue,
      pinCode: pinCode ?? this.pinCode,
    );
  }
}
