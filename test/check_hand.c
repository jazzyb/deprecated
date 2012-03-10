#include <check.h>
#include <holdem/card.h>
#include <holdem/hand.h>

START_TEST (test_hand_init)
{
	txh_hand_t hand;
	txh_card_t cards[4];

	for (int i = 0; i < 4; i++) {
		txh_card_init(cards + i, i, i);
	}
	txh_hand_init(&hand, 4, cards);
	fail_unless(memcmp(hand.cards, cards, sizeof(cards)) == 0);
	fail_unless(hand.type == TXH_NONE);
	fail_unless(hand.n_cards == 4);
}
END_TEST

Suite *hand_suite (void)
{
	Suite *s = suite_create("Hand");
	TCase *tc_hand = tcase_create("Core");
	tcase_add_test(tc_hand, test_hand_init);
	suite_add_tcase(s, tc_hand);
	return s;
}

