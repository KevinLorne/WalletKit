import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../models/card_model.dart';
import 'card_event.dart';
import 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  CardBloc() : super(CardState(cards: [], unlockedCardIds: {})) {
    on<LoadCards>((event, emit) {
      final box = Hive.box<CardModel>('cards');
      final cards = box.values.toList();
      emit(state.copyWith(cards: cards));
    });

    on<AddCard>((event, emit) async {
      final updated = [...state.cards, event.card];
      await Hive.box<CardModel>('cards').put(event.card.id, event.card);
      emit(state.copyWith(cards: updated));
    });

    on<UpdateCardPin>((event, emit) async {
      final box = Hive.box<CardModel>('cards');
      final card = box.get(event.cardId);

      if (card != null) {
        final updatedCard = card.copyWith(pinCode: event.newPin);
        await box.put(event.cardId, updatedCard); // ✅ Update Hive

        final updatedCards =
            state.cards.map((c) {
              return c.id == event.cardId ? updatedCard : c;
            }).toList();

        final updatedUnlockedIds = Set<String>.from(state.unlockedCardIds)
          ..remove(event.cardId); // ✅ Re-lock the card after changing PIN

        emit(
          state.copyWith(
            cards: updatedCards,
            unlockedCardIds: updatedUnlockedIds,
          ),
        );
      }
    });

    on<DeleteCard>((event, emit) async {
      final updated = state.cards.where((c) => c.id != event.cardId).toList();
      await Hive.box<CardModel>('cards').delete(event.cardId);
      final updatedUnlocks = Set<String>.from(state.unlockedCardIds)
        ..remove(event.cardId);
      emit(state.copyWith(cards: updated, unlockedCardIds: updatedUnlocks));
    });

    on<UnlockCard>((event, emit) {
      final updated = Set<String>.from(state.unlockedCardIds)
        ..add(event.cardId);
      emit(state.copyWith(unlockedCardIds: updated));
    });

    on<LockCard>((event, emit) {
      final updated = Set<String>.from(state.unlockedCardIds)
        ..remove(event.cardId);
      emit(state.copyWith(unlockedCardIds: updated));
    });

    on<LockAllCards>((event, emit) {
      emit(state.copyWith(unlockedCardIds: {}));
    });

    on<ToggleExpandCard>((event, emit) {
      final updated =
          state.cards.map((c) {
            if (c.id == event.cardId) {
              return c.copyWith(isExpanded: !c.isExpanded);
            }
            return c;
          }).toList();
      emit(state.copyWith(cards: updated));
    });
  }
}
