#include <check.h>
#include <holdem/card.h>

START_TEST (test_card_init)
{
	txh_card_t card;

	txh_card_init(&card, TXH_A, TXH_SPADES);
	fail_unless(card.rank == TXH_A);
	fail_unless(card.suit == TXH_SPADES);
}
END_TEST

START_TEST (test_card_cmp)
{
	txh_card_t c1, c2, c3, c4;

	txh_card_init(&c1, TXH_J, TXH_DIAMONDS);
	txh_card_init(&c2, TXH_Q, TXH_SPADES);
	txh_card_init(&c3, TXH_3, TXH_HEARTS);
	txh_card_init(&c4, TXH_3, TXH_CLUBS);

	fail_unless(txh_card_cmp(&c1, &c3) > 0);
	fail_unless(txh_card_cmp(&c2, &c1) > 0);
	fail_unless(txh_card_cmp(&c3, &c4) == 0);
}
END_TEST

START_TEST (test_card_copy)
{
	txh_card_t c1, c2;

	txh_card_init(&c1, TXH_2, TXH_HEARTS);
	txh_card_copy(&c2, &c1);
	fail_unless(c2.rank == TXH_2 && c2.suit == TXH_HEARTS);
}
END_TEST

Suite *card_suite (void)
{
	Suite *s = suite_create("Card");
	TCase *tc_card = tcase_create("Core");
	tcase_add_test(tc_card, test_card_init);
	tcase_add_test(tc_card, test_card_cmp);
	tcase_add_test(tc_card, test_card_copy);
	suite_add_tcase(s, tc_card);
	return s;
}

