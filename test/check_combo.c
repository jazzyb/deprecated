#include <check.h>
#include <holdem/card.h>
#include <holdem/combo.h>

START_TEST (test_combo_init)
{
	txh_card_t cards[4];
	txh_combo_iter_t combo;

	for (int i = 0; i < 4; i++) {
		txh_card_init(cards + i, i, i);
	}
	fail_unless(!txh_combo_init(&combo, -1, 4, NULL));
	fail_unless(!txh_combo_init(&combo, 3, 2, NULL));
	fail_unless(!txh_combo_init(&combo, 8, 52, NULL));
	fail_unless(txh_combo_init(&combo, 2, 4, cards));
	txh_combo_free(&combo);
}
END_TEST

START_TEST (test_combo_next)
{
	txh_card_t cards[4];
	for (int i = 0; i < 4; i++) {
		txh_card_init(cards + i, i, i);
	}

	txh_combo_iter_t combo;
	txh_combo_init(&combo, 2, 4, cards);
	int count = 0;
	while (txh_combo_next(&combo)) {
		count += 1;
	}
	fail_unless(count == 6);
	txh_combo_free(&combo);
}
END_TEST

/*
 * Used by test_combo_get_cards test below.
 */
static int list_includes_item (txh_card_t answers[6][2], txh_card_t *cards)
{
	for (int i = 0; i < 6; i++) {
		if ((txh_card_cmp(&answers[i][0], &cards[0]) == 0 &&
		     txh_card_cmp(&answers[i][1], &cards[1]) == 0) ||
		    (txh_card_cmp(&answers[i][0], &cards[1]) == 0 &&
		     txh_card_cmp(&answers[i][1], &cards[0]) == 0)) {
			return 1;
		}
	}
	return 0;
}

START_TEST (test_combo_get_cards)
{
	txh_card_t cards[4];
	for (int i = 0; i < 4; i++) {
		txh_card_init(cards + i, i, i);
	}

	txh_card_t answers[6][2];
	txh_card_init(&answers[0][0], 0, 0);
	txh_card_init(&answers[0][1], 1, 1);
	txh_card_init(&answers[1][0], 0, 0);
	txh_card_init(&answers[1][1], 2, 2);
	txh_card_init(&answers[2][0], 0, 0);
	txh_card_init(&answers[2][1], 3, 3);
	txh_card_init(&answers[3][0], 1, 1);
	txh_card_init(&answers[3][1], 2, 2);
	txh_card_init(&answers[4][0], 1, 1);
	txh_card_init(&answers[4][1], 3, 3);
	txh_card_init(&answers[5][0], 2, 2);
	txh_card_init(&answers[5][1], 3, 3);

	txh_combo_iter_t combo;
	txh_combo_init(&combo, 2, 4, cards);
	while (txh_combo_next(&combo)) {
		txh_card_t *res = txh_combo_get_cards(&combo);
		fail_unless(list_includes_item(answers, res));
	}
	txh_combo_free(&combo);
}
END_TEST

Suite *combo_suite (void)
{
	Suite *s = suite_create("Combo");
	TCase *tc_combo = tcase_create("Core");
	tcase_add_test(tc_combo, test_combo_init);
	tcase_add_test(tc_combo, test_combo_next);
	tcase_add_test(tc_combo, test_combo_get_cards);
	suite_add_tcase(s, tc_combo);
	return s;
}

