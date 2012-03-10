#include <holdem/card.h>

int txh_card_init (txh_card_t *card, txh_rank_t rank, txh_suit_t suit)
{
	card->rank = rank;
	card->suit = suit;
	return 1;
}

int txh_card_cmp (txh_card_t *a, txh_card_t *b)
{
	if (a->rank < b->rank) {
		return -1;
	} else if (a->rank > b->rank) {
		return 1;
	} else {
		return 0;
	}
}

int txh_card_copy (txh_card_t *to, txh_card_t *from)
{
	to->rank = from->rank;
	to->suit = from->suit;
	return 1;
}
