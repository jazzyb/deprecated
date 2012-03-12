#include <assert.h>
#include <stddef.h>
#include <string.h>
#include <strings.h>

#include <holdem/card.h>
#include <holdem/hand.h>

int txh_hand_init (txh_hand_t *hand, size_t size, txh_card_t *cards)
{
	int i;

	if (size < 0 || size > TXH_MAX_CARDS) {
		return 0;
	}

	hand->n_cards = size;
	for (i = 0; i < size; i++) {
		txh_card_copy(hand->cards + i, cards + i);
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

/*
 * Determines and sets the order that the cards in the high hand need to be
 * evaluated.  'ranks' is an array of the number of times a card of a
 * particular rank is in the hand ordered by rank, e.g. rank[TXH_J] will be
 * the number of jacks that are in the high_hand.
 */
static void set_card_order_of_eval (txh_hand_t *hand, int *ranks)
{
	int i, j = 0;
	int pair = 0;

	for (i = TXH_N_RANKS - 1; i >= 0; i--) {
		if (ranks[i] == 0) {
			continue;
		}

		switch (hand->type) {
		case TXH_STRAIGHT_FLUSH:
		case TXH_STRAIGHT:
			/* check for the wheel */
			if (i == TXH_A && ranks[TXH_5]) {
				hand->order_of_eval[TXH_HAND_SIZE - 1] = i;
				break;
			}
			/* fall through */
		case TXH_FLUSH:
		case TXH_HIGH_CARD:
			hand->order_of_eval[j++] = i;
			break;

		case TXH_QUADS:
		case TXH_FULL_HOUSE:
		case TXH_TRIPS:
			if (ranks[i] == 3 || ranks[i] == 4) {
				hand->order_of_eval[0] = i;
			} else {
				hand->order_of_eval[1 + j++] = i;
			}
			break;

		case TXH_TWO_PAIR:
			if (ranks[i] == 2) {
				hand->order_of_eval[pair++] = i;
			} else {
				hand->order_of_eval[2] = i;
			}
			break;

		case TXH_PAIR:
			if (ranks[i] == 2) {
				hand->order_of_eval[0] = i;
			} else {
				hand->order_of_eval[1 + j++] = i;
			}
			break;

		default:
			assert(0);
			break;
		}
	}
}

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
			ranks |= 1; /* check for the wheel */
		}
	}

	for (match = STRAIGHT_MATCH; ranks >= match; ranks >>= 1) {
		if ((ranks & match) == STRAIGHT_MATCH) {
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

/*
 * Determines the hand type of the high hand in 'hand'.  Sets 'hand->type' to
 * the determined value.
 */
static void rank_high_hand (txh_hand_t *hand)
{
	int i, straight, flush;
	int ranks[TXH_N_RANKS];
	txh_rank_t rank;
	txh_hand_type_t type;

	straight = is_straight(hand->high_hand);
	flush = is_flush(hand->high_hand);
	if (straight && flush) {
		type = TXH_STRAIGHT_FLUSH;
	} else if (straight) {
		type = TXH_STRAIGHT;
	} else if (flush) {
		type = TXH_FLUSH;
	} else {
		type = TXH_HIGH_CARD;
	}

	bzero(ranks, TXH_N_RANKS * sizeof(*ranks));
	for (i = 0; i < TXH_HAND_SIZE; i++) {
		rank = txh_card_rank(hand->high_hand + i);
		ranks[rank] += 1;
		switch (ranks[rank]) {
		case 4:
			type = TXH_QUADS;
			break;
		case 3:
			if (type == TXH_PAIR) {
				type = TXH_TRIPS;
			} else if (type == TXH_TWO_PAIR) {
				type = TXH_FULL_HOUSE;
			}
			break;
		case 2:
			if (type == TXH_TRIPS) {
				type = TXH_FULL_HOUSE;
			} else if (type == TXH_PAIR) {
				type = TXH_TWO_PAIR;
			} else {
				type = TXH_PAIR;
			}
			break;
		default:
			break;
		}
	}

	hand->type = type;
	set_card_order_of_eval(hand, ranks);
}

/*
 * Same return condition as txh_hand_cmp below.
 */
static int int_cmp (int a, int b)
{
	if (a > b) {
		return 1;
	} else if (a < b) {
		return -1;
	} else {
		return 0;
	}
}

/*
 * Returns 0 if a and b are equal, 1 if a > b, and -1 if a < b.
 */
int txh_hand_cmp (txh_hand_t *a, txh_hand_t *b)
{
	int i, rc, finish;

	if (a->n_cards < TXH_HAND_SIZE && b->n_cards < TXH_HAND_SIZE) {
		/* unless it's a complete hand, we simply don't care */
		return 0;
	}
	rc = int_cmp(txh_hand_type(a), txh_hand_type(b));
	if (rc) {
		return rc;
	}

	/*
	 * NOTE: Hard-coded numbers.  If the value of TXH_HAND_SIZE ever
	 * changes, then these will need to be changed.  Assumes
	 * TXH_HAND_SIZE == 5.
	 */
	switch (a->type) {
	case TXH_STRAIGHT_FLUSH:
	case TXH_STRAIGHT:
		finish = 1;
		break;
	case TXH_FLUSH:
	case TXH_HIGH_CARD:
		finish = 5;
		break;
	case TXH_QUADS:
	case TXH_FULL_HOUSE:
		finish = 2;
		break;
	case TXH_TRIPS:
	case TXH_TWO_PAIR:
		finish = 3;
		break;
	case TXH_PAIR:
		finish = 4;
		break;
	default:
		finish = 0;
		assert(0);
	}

	for (i = 0; i < finish; i++) {
		rc = int_cmp(a->order_of_eval[i], b->order_of_eval[i]);
		if (rc) {
			return rc;
		}
	}
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
		rank_high_hand(hand);
		return hand->type;
	}

	hand->type = TXH_NONE;
	txh_combo_init(&combo, TXH_HAND_SIZE, hand->n_cards, hand->cards);
	while (txh_combo_next(&combo)) {
		tmp_ptr = txh_combo_get_cards(&combo);
		txh_hand_init(&tmp_hand, TXH_HAND_SIZE, tmp_ptr);
		if (hand->type == TXH_NONE ||
				txh_hand_cmp(&tmp_hand, hand) > 0) {
			hand->type = txh_hand_type(&tmp_hand);
			memcpy(hand->high_hand, tmp_hand.high_hand,
					TXH_HAND_SIZE * sizeof(txh_card_t));
			memcpy(hand->order_of_eval, tmp_hand.order_of_eval,
					TXH_HAND_SIZE * sizeof(txh_rank_t));
		}
	}
	txh_combo_free(&combo);
	return hand->type;
}

int txh_hand_append (txh_hand_t *hand, size_t n_cards, txh_card_t *cards)
{
	int i;

	if (n_cards < 1 || hand->n_cards + n_cards > TXH_MAX_CARDS) {
		return 0;
	}

	for (i = 0; i < n_cards; i++) {
		txh_card_copy(hand->cards + hand->n_cards + i, cards + i);
	}
	hand->n_cards += n_cards;
	hand->type = TXH_UNKNOWN;
	return 1;
}

