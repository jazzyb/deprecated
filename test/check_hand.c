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
	fail_unless(hand.type == TXH_UNKNOWN);
	fail_unless(hand.n_cards == 4);
}
END_TEST

START_TEST (test_high_card)
{
	txh_hand_t hand;
	txh_card_t cards[5];

	txh_card_init(&cards[0], TXH_6, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_T, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_2, TXH_SPADES);
	txh_card_init(&cards[3], TXH_4, TXH_DIAMONDS);
	txh_card_init(&cards[4], TXH_9, TXH_HEARTS);

	txh_hand_init(&hand, 5, cards);
	fail_unless(txh_hand_type(&hand) == TXH_HIGH_CARD);
	fail_unless(hand.order_of_eval[0] == TXH_T);
	fail_unless(hand.order_of_eval[1] == TXH_9);
	fail_unless(hand.order_of_eval[2] == TXH_6);
	fail_unless(hand.order_of_eval[3] == TXH_4);
	fail_unless(hand.order_of_eval[4] == TXH_2);
}
END_TEST

START_TEST (test_pair)
{
	txh_hand_t hand;
	txh_card_t cards[6];

	txh_card_init(&cards[0], TXH_6, TXH_SPADES);
	txh_card_init(&cards[1], TXH_5, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_9, TXH_DIAMONDS);
	txh_card_init(&cards[3], TXH_5, TXH_SPADES);
	txh_card_init(&cards[4], TXH_A, TXH_SPADES);
	txh_card_init(&cards[5], TXH_K, TXH_DIAMONDS);

	txh_hand_init(&hand, 6, cards);
	fail_unless(txh_hand_type(&hand) == TXH_PAIR);
	fail_unless(hand.order_of_eval[0] == TXH_5);
	fail_unless(hand.order_of_eval[1] == TXH_A);
	fail_unless(hand.order_of_eval[2] == TXH_K);
	fail_unless(hand.order_of_eval[3] == TXH_9);
}
END_TEST

START_TEST (test_two_pair)
{
	txh_hand_t hand;
	txh_card_t cards[5];

	txh_card_init(&cards[0], TXH_T, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_8, TXH_SPADES);
	txh_card_init(&cards[2], TXH_T, TXH_CLUBS);
	txh_card_init(&cards[3], TXH_2, TXH_DIAMONDS);
	txh_card_init(&cards[4], TXH_2, TXH_SPADES);

	txh_hand_init(&hand, 5, cards);
	fail_unless(txh_hand_type(&hand) == TXH_TWO_PAIR);
	fail_unless(hand.order_of_eval[0] == TXH_T);
	fail_unless(hand.order_of_eval[1] == TXH_2);
	fail_unless(hand.order_of_eval[2] == TXH_8);
}
END_TEST

START_TEST (test_trips)
{
	txh_hand_t hand;
	txh_card_t cards[6];

	txh_card_init(&cards[0], TXH_9, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_6, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_7, TXH_CLUBS);
	txh_card_init(&cards[3], TXH_9, TXH_CLUBS);
	txh_card_init(&cards[4], TXH_A, TXH_DIAMONDS);
	txh_card_init(&cards[5], TXH_9, TXH_SPADES);

	txh_hand_init(&hand, 6, cards);
	fail_unless(txh_hand_type(&hand) == TXH_TRIPS);
	fail_unless(hand.order_of_eval[0] == TXH_9);
	fail_unless(hand.order_of_eval[1] == TXH_A);
	fail_unless(hand.order_of_eval[2] == TXH_7);
}
END_TEST

START_TEST (test_straight)
{
	txh_hand_t hand;
	txh_card_t cards[5];

	txh_card_init(&cards[0], TXH_5, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_4, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_3, TXH_HEARTS);
	txh_card_init(&cards[3], TXH_6, TXH_CLUBS);
	txh_card_init(&cards[4], TXH_2, TXH_SPADES);

	txh_hand_init(&hand, 5, cards);
	fail_unless(txh_hand_type(&hand) == TXH_STRAIGHT);
	fail_unless(hand.order_of_eval[0] == TXH_6);
	fail_unless(hand.order_of_eval[1] == TXH_5);
	fail_unless(hand.order_of_eval[2] == TXH_4);
	fail_unless(hand.order_of_eval[3] == TXH_3);
	fail_unless(hand.order_of_eval[4] == TXH_2);

	txh_card_init(&cards[3], TXH_A, TXH_CLUBS);
	txh_hand_init(&hand, 5, cards);
	fail_unless(txh_hand_type(&hand) == TXH_STRAIGHT);
	fail_unless(hand.order_of_eval[0] == TXH_5);
	fail_unless(hand.order_of_eval[1] == TXH_4);
	fail_unless(hand.order_of_eval[2] == TXH_3);
	fail_unless(hand.order_of_eval[3] == TXH_2);
	fail_unless(hand.order_of_eval[4] == TXH_A);
}
END_TEST

START_TEST (test_flush)
{
	txh_hand_t hand;
	txh_card_t cards[6];

	txh_card_init(&cards[0], TXH_2, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_T, TXH_DIAMONDS);
	txh_card_init(&cards[2], TXH_4, TXH_DIAMONDS);
	txh_card_init(&cards[3], TXH_6, TXH_DIAMONDS);
	txh_card_init(&cards[4], TXH_A, TXH_SPADES);
	txh_card_init(&cards[5], TXH_9, TXH_DIAMONDS);

	txh_hand_init(&hand, 6, cards);
	fail_unless(txh_hand_type(&hand) == TXH_FLUSH);
	fail_unless(hand.order_of_eval[0] == TXH_T);
	fail_unless(hand.order_of_eval[1] == TXH_9);
	fail_unless(hand.order_of_eval[2] == TXH_6);
	fail_unless(hand.order_of_eval[3] == TXH_4);
	fail_unless(hand.order_of_eval[4] == TXH_2);
}
END_TEST

START_TEST (test_full_house)
{
	txh_hand_t hand;
	txh_card_t cards[6];

	txh_card_init(&cards[0], TXH_T, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_T, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_7, TXH_DIAMONDS);
	txh_card_init(&cards[3], TXH_K, TXH_DIAMONDS);
	txh_card_init(&cards[4], TXH_T, TXH_HEARTS);
	txh_card_init(&cards[5], TXH_7, TXH_CLUBS);

	txh_hand_init(&hand, 6, cards);
	fail_unless(txh_hand_type(&hand) == TXH_FULL_HOUSE);
	fail_unless(hand.order_of_eval[0] == TXH_T);
	fail_unless(hand.order_of_eval[1] == TXH_7);
}
END_TEST

START_TEST (test_quads)
{
	txh_hand_t hand;
	txh_card_t cards[7];

	txh_card_init(&cards[0], TXH_9, TXH_DIAMONDS);
	txh_card_init(&cards[1], TXH_9, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_9, TXH_SPADES);
	txh_card_init(&cards[3], TXH_7, TXH_DIAMONDS);
	txh_card_init(&cards[4], TXH_9, TXH_HEARTS);
	txh_card_init(&cards[5], TXH_7, TXH_CLUBS);
	txh_card_init(&cards[6], TXH_6, TXH_CLUBS);

	txh_hand_init(&hand, 7, cards);
	fail_unless(txh_hand_type(&hand) == TXH_QUADS);
	fail_unless(hand.order_of_eval[0] == TXH_9);
	fail_unless(hand.order_of_eval[1] == TXH_7);
}
END_TEST

START_TEST (test_straight_flush)
{
	txh_hand_t hand;
	txh_card_t cards[7];

	txh_card_init(&cards[0], TXH_6, TXH_CLUBS);
	txh_card_init(&cards[1], TXH_7, TXH_CLUBS);
	txh_card_init(&cards[2], TXH_8, TXH_CLUBS);
	txh_card_init(&cards[3], TXH_9, TXH_CLUBS);
	txh_card_init(&cards[4], TXH_T, TXH_CLUBS);
	txh_card_init(&cards[5], TXH_J, TXH_DIAMONDS);
	txh_card_init(&cards[6], TXH_Q, TXH_HEARTS);

	txh_hand_init(&hand, 7, cards);
	fail_unless(txh_hand_type(&hand) == TXH_STRAIGHT_FLUSH);
	fail_unless(hand.order_of_eval[0] == TXH_T);
	fail_unless(hand.order_of_eval[1] == TXH_9);
	fail_unless(hand.order_of_eval[2] == TXH_8);
	fail_unless(hand.order_of_eval[3] == TXH_7);
	fail_unless(hand.order_of_eval[4] == TXH_6);
}
END_TEST

START_TEST (test_hand_cmp)
{
	txh_hand_t h1, h2;
	txh_card_t c1[6];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_8, TXH_DIAMONDS);
	txh_card_init(&c1[1], TXH_6, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_2, TXH_SPADES);
	txh_card_init(&c1[4], TXH_5, TXH_DIAMONDS);
	txh_card_init(&c1[5], TXH_9, TXH_HEARTS);
	txh_hand_init(&h1, 6, c1);

	txh_card_init(&c2[0], TXH_T, TXH_DIAMONDS);
	txh_card_init(&c2[1], TXH_8, TXH_SPADES);
	txh_card_init(&c2[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c2[3], TXH_2, TXH_SPADES);
	txh_card_init(&c2[4], TXH_2, TXH_DIAMONDS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) < 0);
}
END_TEST

START_TEST (test_cmp_high_cards)
{
	txh_hand_t h1, h2;
	txh_card_t c1[6];
	txh_card_t c2[6];

	txh_card_init(&c1[0], TXH_8, TXH_DIAMONDS);
	txh_card_init(&c1[1], TXH_6, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_2, TXH_SPADES);
	txh_card_init(&c1[4], TXH_4, TXH_DIAMONDS);
	txh_card_init(&c1[5], TXH_9, TXH_HEARTS);
	txh_hand_init(&h1, 6, c1);

	txh_card_init(&c2[0], TXH_8, TXH_DIAMONDS);
	txh_card_init(&c2[1], TXH_6, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c2[3], TXH_2, TXH_SPADES);
	txh_card_init(&c2[4], TXH_5, TXH_DIAMONDS);
	txh_card_init(&c2[5], TXH_9, TXH_HEARTS);
	txh_hand_init(&h2, 6, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) < 0);
}
END_TEST

START_TEST (test_cmp_pairs)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_9, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_9, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_A, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_Q, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_T, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_6, TXH_SPADES);
	txh_card_init(&c2[1], TXH_4, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_T, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_2, TXH_SPADES);
	txh_card_init(&c2[4], TXH_T, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) < 0);

	txh_card_init(&c1[0], TXH_2, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_2, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_5, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_8, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_4, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_2, TXH_SPADES);
	txh_card_init(&c2[1], TXH_2, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_3, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_8, TXH_SPADES);
	txh_card_init(&c2[4], TXH_5, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);
}
END_TEST

START_TEST (test_cmp_two_pairs)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_K, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_K, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_2, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_2, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_J, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_J, TXH_SPADES);
	txh_card_init(&c2[1], TXH_J, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_T, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_T, TXH_SPADES);
	txh_card_init(&c2[4], TXH_9, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c1[0], TXH_9, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_9, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_7, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_7, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_6, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_9, TXH_SPADES);
	txh_card_init(&c2[1], TXH_9, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_5, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_5, TXH_SPADES);
	txh_card_init(&c2[4], TXH_K, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c1[0], TXH_4, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_4, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_3, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_3, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_K, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_4, TXH_SPADES);
	txh_card_init(&c2[1], TXH_4, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_3, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_3, TXH_SPADES);
	txh_card_init(&c2[4], TXH_J, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);
}
END_TEST

START_TEST (test_cmp_trips)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_Q, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_Q, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_Q, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_5, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_3, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_5, TXH_SPADES);
	txh_card_init(&c2[1], TXH_5, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_5, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_K, TXH_SPADES);
	txh_card_init(&c2[4], TXH_T, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c1[0], TXH_8, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_8, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_8, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_A, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_2, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_8, TXH_SPADES);
	txh_card_init(&c2[1], TXH_8, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_8, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_5, TXH_SPADES);
	txh_card_init(&c2[4], TXH_3, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);
}
END_TEST

START_TEST (test_cmp_straights)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_8, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_7, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_6, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_5, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_4, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_6, TXH_SPADES);
	txh_card_init(&c2[1], TXH_5, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_4, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_3, TXH_SPADES);
	txh_card_init(&c2[4], TXH_2, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c2[0], TXH_8, TXH_SPADES);
	txh_card_init(&c2[1], TXH_7, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_6, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_5, TXH_SPADES);
	txh_card_init(&c2[4], TXH_4, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) == 0);
}
END_TEST

START_TEST (test_cmp_flushes)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_A, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_Q, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_5, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_3, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_K, TXH_SPADES);
	txh_card_init(&c2[1], TXH_Q, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_J, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_9, TXH_SPADES);
	txh_card_init(&c2[4], TXH_6, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c1[0], TXH_A, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_K, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_7, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_6, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_2, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_A, TXH_SPADES);
	txh_card_init(&c2[1], TXH_Q, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_T, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_5, TXH_SPADES);
	txh_card_init(&c2[4], TXH_3, TXH_SPADES);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);
}
END_TEST

START_TEST (test_cmp_full_houses)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_4, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_4, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_T, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_T, TXH_SPADES);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_9, TXH_SPADES);
	txh_card_init(&c2[1], TXH_9, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_9, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_A, TXH_SPADES);
	txh_card_init(&c2[4], TXH_A, TXH_CLUBS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c1[0], TXH_A, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_A, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_A, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_4, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_4, TXH_SPADES);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_A, TXH_HEARTS);
	txh_card_init(&c2[1], TXH_3, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_3, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_A, TXH_SPADES);
	txh_card_init(&c2[4], TXH_A, TXH_CLUBS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);
}
END_TEST

START_TEST (test_cmp_quads)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_T, TXH_SPADES);
	txh_card_init(&c1[1], TXH_T, TXH_DIAMONDS);
	txh_card_init(&c1[2], TXH_T, TXH_CLUBS);
	txh_card_init(&c1[3], TXH_T, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_5, TXH_SPADES);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_6, TXH_SPADES);
	txh_card_init(&c2[1], TXH_6, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_6, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_6, TXH_CLUBS);
	txh_card_init(&c2[4], TXH_7, TXH_CLUBS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c2[0], TXH_T, TXH_SPADES);
	txh_card_init(&c2[1], TXH_T, TXH_DIAMONDS);
	txh_card_init(&c2[2], TXH_T, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_T, TXH_CLUBS);
	txh_card_init(&c2[4], TXH_Q, TXH_CLUBS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) < 0);
}
END_TEST

START_TEST (test_cmp_straight_flushes)
{
	txh_hand_t h1, h2;
	txh_card_t c1[5];
	txh_card_t c2[5];

	txh_card_init(&c1[0], TXH_7, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_6, TXH_HEARTS);
	txh_card_init(&c1[2], TXH_5, TXH_HEARTS);
	txh_card_init(&c1[3], TXH_4, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_3, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_5, TXH_HEARTS);
	txh_card_init(&c2[1], TXH_4, TXH_HEARTS);
	txh_card_init(&c2[2], TXH_3, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_2, TXH_HEARTS);
	txh_card_init(&c2[4], TXH_A, TXH_HEARTS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) > 0);

	txh_card_init(&c1[0], TXH_J, TXH_HEARTS);
	txh_card_init(&c1[1], TXH_T, TXH_HEARTS);
	txh_card_init(&c1[2], TXH_9, TXH_HEARTS);
	txh_card_init(&c1[3], TXH_8, TXH_HEARTS);
	txh_card_init(&c1[4], TXH_7, TXH_HEARTS);
	txh_hand_init(&h1, 5, c1);

	txh_card_init(&c2[0], TXH_J, TXH_HEARTS);
	txh_card_init(&c2[1], TXH_T, TXH_HEARTS);
	txh_card_init(&c2[2], TXH_9, TXH_HEARTS);
	txh_card_init(&c2[3], TXH_8, TXH_HEARTS);
	txh_card_init(&c2[4], TXH_7, TXH_HEARTS);
	txh_hand_init(&h2, 5, c2);

	fail_unless(txh_hand_cmp(&h1, &h2) == 0);
}
END_TEST

Suite *hand_suite (void)
{
	Suite *s = suite_create("Hand");
	TCase *tc_hand = tcase_create("Core");
	tcase_add_test(tc_hand, test_hand_init);
	tcase_add_test(tc_hand, test_high_card);
	tcase_add_test(tc_hand, test_pair);
	tcase_add_test(tc_hand, test_two_pair);
	tcase_add_test(tc_hand, test_trips);
	tcase_add_test(tc_hand, test_straight);
	tcase_add_test(tc_hand, test_flush);
	tcase_add_test(tc_hand, test_full_house);
	tcase_add_test(tc_hand, test_quads);
	tcase_add_test(tc_hand, test_straight_flush);
	tcase_add_test(tc_hand, test_hand_cmp);
	tcase_add_test(tc_hand, test_cmp_high_cards);
	tcase_add_test(tc_hand, test_cmp_pairs);
	tcase_add_test(tc_hand, test_cmp_two_pairs);
	tcase_add_test(tc_hand, test_cmp_trips);
	tcase_add_test(tc_hand, test_cmp_straights);
	tcase_add_test(tc_hand, test_cmp_flushes);
	tcase_add_test(tc_hand, test_cmp_full_houses);
	tcase_add_test(tc_hand, test_cmp_quads);
	tcase_add_test(tc_hand, test_cmp_straight_flushes);
	suite_add_tcase(s, tc_hand);
	return s;
}

