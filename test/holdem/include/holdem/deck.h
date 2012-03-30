#ifndef _HOLDEM_DECK_H_
#define _HOLDEM_DECK_H_

#include <stddef.h>

#include <holdem/card.h>

#define TXH_MAX_DECK_SIZE 52

typedef struct {
	txh_card_t cards[TXH_MAX_DECK_SIZE];
	size_t n_cards;
} txh_deck_t;

/*
 * Initializes a new deck.  'minus' points to a list of 'count' cards that
 * should NOT be in the deck.  If no cards should be excluded from the deck,
 * then the caller should set 'count' to 0 and 'minus' to NULL.
 */
int txh_deck_init (txh_deck_t *deck, size_t count, txh_card_t *minus);

txh_card_t *txh_deck_cards (txh_deck_t *deck);

int txh_deck_size (txh_deck_t *deck);

/*
 * Removes 'num' cards from the deck and places them into 'cards'.  The caller
 * must insure that there is enough space pointed to by 'cards' to copy 'num'
 * cards.  Returns 0 if there are not enough cards in deck to fulfill the
 * deal; 1 for success.
 */
int txh_deck_deal (txh_deck_t *deck, txh_card_t *cards, int num);

/*
 * Shuffles the deck using the subroutine random_cb to generate random
 * numbers.  If random_cb is NULL, then stdlib's rand() is used.  The function
 * assumes that the caller has seeded the random number generator before-hand.
 */
void txh_deck_shuffle (txh_deck_t *deck, int (*random_cb)(void));

#endif
