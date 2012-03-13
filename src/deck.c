#include <stddef.h>

#include <holdem/card.h>
#include <holdem/deck.h>

static int list_includes_card (txh_card_t *minus, int count, txh_card_t *card)
{
	int i;

	for (i = 0; i < count; i++) {
		if (txh_card_is_equal(card, minus + i)) {
			return 1;
		}
	}
	return 0;
}

int txh_deck_init (txh_deck_t *deck, size_t count, txh_card_t *minus)
{
	int i, j;
	txh_card_t card;

	if (count < 0 || count > TXH_MAX_DECK_SIZE) {
		return 0;
	}

	deck->n_cards = 0;
	for (i = 0; i < TXH_N_RANKS; i++) {
		for (j = 0; j < TXH_N_SUITS; j++) {
			txh_card_init(&card, i, j);
			if (minus && list_includes_card(minus, count, &card)) {
				continue;
			}
			txh_card_copy(deck->cards + deck->n_cards, &card);
			deck->n_cards += 1;
		}
	}
	return 1;
}

txh_card_t *txh_deck_cards (txh_deck_t *deck)
{
	return deck->cards;
}

int txh_deck_size (txh_deck_t *deck)
{
	return deck->n_cards;
}

int txh_deck_deal (txh_deck_t *deck, txh_card_t *cards, int num)
{
	int i, idx;

	if (num < 0 || num > deck->n_cards) {
		return 0;
	}

	/* remove cards from the "back" of the deck */
	for (i = 0; i < num; i++) {
		idx = deck->n_cards - i - 1;
		txh_card_copy(cards + i, deck->cards + idx);
	}
	deck->n_cards -= num;
	return 1;
}

