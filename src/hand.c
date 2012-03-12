#include <stddef.h>
#include <string.h>
#include <strings.h>

#include <holdem/card.h>
#include <holdem/hand.h>

int txh_hand_init (txh_hand_t *hand, size_t size, txh_card_t *cards)
{
	int i;

	hand->n_cards = size;
	if (size > 0) {
		for (i = 0; i < size; i++) {
			txh_card_copy(hand->cards + i, cards + i);
		}
	}
	hand->type = TXH_UNKNOWN;
	return 1;
}

txh_card_t *txh_hand_cards (txh_hand_t *hand)
{
	return hand->cards;
}

int txh_hand_size (txh_hand_t *hand)
{
	return hand->n_cards;
}

#define STRAIGHT_MATCH 0x1f

static int is_straight (txh_card_t *cards)
{
	int i;
	txh_rank_t rank;
	unsigned int ranks, match;

	ranks = 0;
	for (i = 0; i < TXH_HAND_SIZE; i++) {
		rank = txh_card_rank(cards + i);
		ranks |= 1 << (rank + 1);
		if (rank == TXH_A) {
			ranks |= 1; /* checking for the wheel */
		}
	}

	for (match = STRAIGHT_MATCH; ranks >= match; match <<= 1) {
		if (ranks == match) {
			return 1;
		}
	}
	return 0;
}

static int is_flush (txh_card_t *cards)
{
	return  txh_card_suit(&cards[0]) == txh_card_suit(&cards[1]) &&
		txh_card_suit(&cards[1]) == txh_card_suit(&cards[2]) &&
		txh_card_suit(&cards[2]) == txh_card_suit(&cards[3]) &&
		txh_card_suit(&cards[3]) == txh_card_suit(&cards[4]);
}

static txh_hand_type_t rank_cards (txh_card_t *cards)
{
	int i, straight, flush;
	int ranks[TXH_N_RANKS];
	txh_rank_t rank;
	txh_hand_type_t type;

	straight = is_straight(cards);
	flush = is_flush(cards);
	if (straight && flush) {
		return TXH_STRAIGHT_FLUSH;
	} else if (straight) {
		return TXH_STRAIGHT;
	} else if (flush) {
		return TXH_FLUSH;
	}

	type = TXH_HIGH_CARD;
	bzero(ranks, TXH_N_RANKS * sizeof(int));
	for (i = 0; i < TXH_HAND_SIZE; i++) {
		rank = txh_card_rank(cards + i);
		ranks[rank] += 1;
		switch (ranks[rank]) {
		case 4:
			return TXH_QUADS;
		case 3:
			if (type == TXH_PAIR) {
				type = TXH_TRIPS;
			} else if (type == TXH_TWO_PAIR) {
				return TXH_FULL_HOUSE;
			}
			break;
		case 2:
			if (type == TXH_TRIPS) {
				return TXH_FULL_HOUSE;
			} else if (type == TXH_PAIR) {
				type = TXH_TWO_PAIR;
			} else {
				type = TXH_PAIR;
			}
			break;
		default: break;
		}
	}
	return type;
}

int txh_hand_cmp (txh_hand_t *a, txh_hand_t *b)
{
	txh_hand_type_t a_type, b_type;

	a_type = txh_hand_type(a);
	b_type = txh_hand_type(b);
	if (a_type > b_type) {
		return 1;
	} else if (a_type < b_type) {
		return -1;
	}
	/* TODO If they are equal, then compare attributes. */
	return 0;
}

txh_hand_type_t txh_hand_type (txh_hand_t *hand)
{
	txh_card_t *tmp_ptr;
	txh_hand_t tmp_hand;
	txh_combo_iter_t combo;

	if (hand->type != TXH_UNKNOWN) {
		return hand->type;
	} else if (hand->n_cards < TXH_HAND_SIZE) {
		hand->type = TXH_NONE;
		return TXH_NONE;
	} else if (hand->n_cards == TXH_HAND_SIZE) {
		memcpy(hand->high_hand, hand->cards,
				TXH_HAND_SIZE * sizeof(txh_card_t));
		hand->type = rank_cards(hand->high_hand);
		return hand->type;
	}

	hand->type = TXH_NONE;
	txh_combo_init(&combo, TXH_HAND_SIZE, hand->n_cards, hand->cards);
	while (txh_combo_next(&combo)) {
		tmp_ptr = txh_combo_get_cards(&combo);
		txh_hand_init(&tmp_hand, TXH_HAND_SIZE, tmp_ptr);
		if (hand->type == TXH_NONE ||
				txh_hand_cmp(&tmp_hand, hand) > 0) {
			hand->type = tmp_hand.type;
			memcpy(hand->high_hand, tmp_hand.high_hand,
					TXH_HAND_SIZE * sizeof(txh_card_t));
		}
	}
	txh_combo_free(&combo);
	return hand->type;
}

