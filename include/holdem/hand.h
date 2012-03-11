#ifndef _HOLDEM_HAND_H_
#define _HOLDEM_HAND_H_

#include <stddef.h>

#include <holdem/card.h>
#include <holdem/combo.h>

typedef enum {
	TXH_NONE = 0,
	TXH_HIGH_CARD,
	TXH_PAIR,
	TXH_TWO_PAIR,
	TXH_TRIPS,
	TXH_STRAIGHT,
	TXH_FLUSH,
	TXH_FULL_HOUSE,
	TXH_QUADS,
	TXH_STRAIGHT_FLUSH,
	TXH_N_HAND_CATS
} txh_hand_cat_t;

/* the number of cards that make up a poker hand */
#define TXH_HAND_SIZE 5

typedef struct {
	txh_hand_cat_t type;
	txh_card_t cards[TXH_MAX_CARDS];
	size_t n_cards;
	/* 'high_hand' is the best hand given the cards in 'cards'
	 * 'high_hand' is only set if 'n_cards' is >= 5 */
	txh_card_t *high_hand[TXH_HAND_SIZE];
} txh_hand_t;

/*
 * Takes an array of cards along with the number of cards in the array (size)
 * and copies the contents of the array into the 'cards' array.  If 'size' is
 * 0, then 'type' is simply set to TXH_NONE.
 */
int txh_hand_init (txh_hand_t *hand, size_t size, txh_card_t *cards);

#endif
