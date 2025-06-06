import 'package:walletkit/models/card_model.dart';

abstract class CardEvent {}

class AddCard extends CardEvent {
  final CardModel card;
  AddCard(this.card);
}

class UpdateCard extends CardEvent {
  final CardModel card;
  UpdateCard(this.card);
}

class DeleteCard extends CardEvent {
  final String cardId;
  DeleteCard(this.cardId);
}

class ToggleExpandCard extends CardEvent {
  final String cardId;
  ToggleExpandCard(this.cardId);
}

class UpdateCardPin extends CardEvent {
  final String cardId;
  final String newPin;

  UpdateCardPin(this.cardId, this.newPin);
}

class UnlockCard extends CardEvent {
  final String cardId;
  UnlockCard(this.cardId);
}

class LockCard extends CardEvent {
  final String cardId;
  LockCard(this.cardId);
}

class LockAllCards extends CardEvent {}

class LoadCards extends CardEvent {}
