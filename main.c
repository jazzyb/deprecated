/*
 * FIXME
 * I'm leaving this file here for now to remind myself of how to use this API,
 * but it will get removed in the future.
 */
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <time.h>

#include <holdem/card.h>
#include <holdem/combo.h>
#include <holdem/deck.h>
#include <holdem/hand.h>

#define FORTY_NINE_CHOOSE_FOUR 211876

static int compar (const void *a, const void *b)
{
	return txh_hand_cmp((txh_hand_t *)a, (txh_hand_t *)b);
}

int main (void)
{
	int i, count = 0;
	txh_deck_t deck;
	txh_hand_t flop, hand;
	txh_card_t flop_cards[3];
	txh_combo_iter_t combo;
	txh_hand_t *all_hands;
	int types[TXH_N_HAND_TYPES];

	all_hands = calloc(FORTY_NINE_CHOOSE_FOUR, sizeof(*all_hands));
	if (!all_hands) {
		fprintf(stderr, "could not allocate space for hands\n");
		return EXIT_FAILURE;
	}
	bzero(types, TXH_N_RANKS * sizeof(int));

	txh_card_init(&flop_cards[0], TXH_A, TXH_CLUBS);
	txh_card_init(&flop_cards[1], TXH_7, TXH_SPADES);
	txh_card_init(&flop_cards[2], TXH_5, TXH_CLUBS);

	txh_deck_init(&deck, 3, flop_cards);
	srand(time(NULL));
	txh_deck_shuffle(&deck, NULL);

	txh_combo_init(&combo, 4, txh_deck_size(&deck), txh_deck_cards(&deck));
	while (txh_combo_next(&combo)) {
		txh_hand_init(&hand, 3, flop_cards);
		txh_hand_append(&hand, 4, txh_combo_get_cards(&combo));
		types[txh_hand_type(&hand)] += 1;
		txh_hand_copy(all_hands + count, &hand);
		count += 1;
	}
	txh_combo_free(&combo);

	for (i = TXH_HIGH_CARD; i < TXH_N_HAND_TYPES; i++) {
		printf("%d: %d\n", i, types[i]);
	}
	printf("T: %d\n", count);

	qsort(all_hands, FORTY_NINE_CHOOSE_FOUR, sizeof(*all_hands), &compar);

	return EXIT_SUCCESS;
}
