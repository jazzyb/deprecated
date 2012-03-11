#include <stddef.h>

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
	hand->type = TXH_NONE;
	return 1;
}

