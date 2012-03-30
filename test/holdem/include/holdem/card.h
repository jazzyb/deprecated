#ifndef _HOLDEM_CARD_H_
#define _HOLDEM_CARD_H_

typedef enum {
	TXH_2 = 0,
	TXH_3,
	TXH_4,
	TXH_5,
	TXH_6,
	TXH_7,
	TXH_8,
	TXH_9,
	TXH_T,
	TXH_J,
	TXH_Q,
	TXH_K,
	TXH_A,
	TXH_N_RANKS
} txh_rank_t;

typedef enum {
	TXH_CLUBS = 0,
	TXH_DIAMONDS,
	TXH_HEARTS,
	TXH_SPADES,
	TXH_N_SUITS
} txh_suit_t;

typedef struct {
	txh_rank_t rank;
	txh_suit_t suit;
} txh_card_t;

int txh_card_init (txh_card_t *card, txh_rank_t rank, txh_suit_t suit);

txh_rank_t txh_card_rank (txh_card_t *card);

txh_suit_t txh_card_suit (txh_card_t *card);

int txh_card_cmp (txh_card_t *a, txh_card_t *b);

int txh_card_is_equal (txh_card_t *a, txh_card_t *b);

int txh_card_copy (txh_card_t *to, txh_card_t *from);

#endif
