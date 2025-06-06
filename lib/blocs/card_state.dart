import 'package:walletkit/models/card_model.dart';

class CardState {
  final List<CardModel> cards;
  final Set<String> unlockedCardIds;

  CardState({required this.cards, this.unlockedCardIds = const {}});

  CardState copyWith({List<CardModel>? cards, Set<String>? unlockedCardIds}) {
    return CardState(
      cards: cards ?? this.cards,
      unlockedCardIds: unlockedCardIds ?? this.unlockedCardIds,
    );
  }
}
