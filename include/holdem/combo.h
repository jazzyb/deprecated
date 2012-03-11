#ifndef _HOLDEM_COMBO_H_
#define _HOLDEM_COMBO_H_

#include <stddef.h>

#include <holdem/card.h>

/* the maximum number of cards each player can have per hand in texas holdem */
#define TXH_MAX_CARDS 7

typedef struct {
	txh_card_t combo[TXH_MAX_CARDS];
	size_t combo_size;
	txh_card_t *src;
	size_t src_size;
	int indices[TXH_MAX_CARDS];
	int done_flag;
} txh_combo_iter_t;

int txh_combo_init (txh_combo_iter_t *combo, size_t combo_size,
		size_t src_size, txh_card_t *src);

/*
 * Readies the next iteration of the combo.  Returns 1 if new combination was
 * successfully readied.  Returns 0 if there are no new combonations.
 */
int txh_combo_next (txh_combo_iter_t *combo);

/*
 * Returns a pointer to the card array that was readied by txh_combo_next.
 */
txh_card_t *txh_combo_get_cards (txh_combo_iter_t *combo);

void txh_combo_free (txh_combo_iter_t *combo);

#endif
