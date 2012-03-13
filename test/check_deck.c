#include <check.h>
#include <holdem/card.h>
#include <holdem/deck.h>
#include <stdlib.h>

static int list_includes_card (txh_card_t *list, int count, txh_card_t *card)
{
	int i;

	for (i = 0; i < count; i++) {
		if (txh_card_is_equal(card, list + i)) {
			return 1;
		}
	}
	return 0;
}

START_TEST (test_deck_init)
{
	txh_deck_t deck;
	fail_unless(txh_deck_init(&deck, 0, NULL));
	fail_unless(txh_deck_size(&deck) == 52);
	fail_unless(!txh_deck_init(&deck, -1, NULL));
	fail_unless(!txh_deck_init(&deck, 53, NULL));

	txh_card_t minus[2];
	txh_card_init(&minus[0], TXH_5, TXH_HEARTS);
	txh_card_init(&minus[1], TXH_J, TXH_SPADES);
	fail_unless(txh_deck_init(&deck, 2, minus));
	fail_unless(txh_deck_size(&deck) == 50);
	fail_unless(!list_includes_card(txh_deck_cards(&deck), 50, &minus[0]));
	fail_unless(!list_includes_card(txh_deck_cards(&deck), 50, &minus[1]));
}
END_TEST

START_TEST (test_deck_deal)
{
	txh_deck_t deck;
	txh_card_t cards[2];
	fail_unless(txh_deck_init(&deck, 0, NULL));
	fail_unless(txh_deck_deal(&deck, cards, 2));

	txh_card_t answers[2];
	txh_card_init(&answers[0], TXH_A, TXH_SPADES);
	txh_card_init(&answers[1], TXH_A, TXH_HEARTS);
	fail_unless(txh_card_is_equal(&cards[0], &answers[0]));
	fail_unless(txh_card_is_equal(&cards[1], &answers[1]));
}
END_TEST

START_TEST (test_deck_shuffle)
{
	txh_deck_t deck;
	txh_deck_init(&deck, 0, NULL);
	srand(1234567890);
	txh_deck_shuffle(&deck, NULL);
	fail_unless(deck.cards[0].rank == TXH_3 && deck.cards[0].suit == TXH_HEARTS);
	fail_unless(deck.cards[1].rank == TXH_5 && deck.cards[1].suit == TXH_SPADES);
	txh_deck_shuffle(&deck, &rand);
	fail_unless(deck.cards[0].rank == TXH_8 && deck.cards[0].suit == TXH_CLUBS);
	fail_unless(deck.cards[1].rank == TXH_9 && deck.cards[1].suit == TXH_SPADES);
}
END_TEST

Suite *deck_suite (void)
{
	Suite *s = suite_create("Deck");
	TCase *tc_deck = tcase_create("Core");
	tcase_add_test(tc_deck, test_deck_init);
	tcase_add_test(tc_deck, test_deck_deal);
	tcase_add_test(tc_deck, test_deck_shuffle);
	suite_add_tcase(s, tc_deck);
	return s;
}
