#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

#include <holdem/card.h>
#include <holdem/combo.h>

int txh_combo_init (txh_combo_iter_t *combo, size_t combo_size,
		size_t src_size, txh_card_t *src)
{
	int i;

	if (combo_size < 1 || combo_size > TXH_MAX_CARDS ||
			combo_size > src_size) {
		return 0;
	}
	combo->combo_size = combo_size;
	for (i = 0; i < combo_size; i++) {
		combo->indices[i] = i;
	}

	combo->src_size = src_size;
	combo->src = calloc(src_size, sizeof(*src));
	if (!combo->src) {
		return 0;
	}
	for (i = 0; i < src_size; i++) {
		txh_card_copy(combo->src + i, src + i);
	}

	combo->done_flag = 0;
	return 1;
}

/*
 * See the comments above txh_combo_next for an explanation of this function.
 */
static void set_combo_array (txh_combo_iter_t *combo)
{
	int i, idx;

	for (i = 0; i < combo->combo_size; i++) {
		idx = combo->indices[i];
		txh_card_copy(combo->combo + i, combo->src + idx);
	}
}

/*
 * See the comments above txh_combo_next for an explanation of this function.
 */
static int increment_next_index (txh_combo_iter_t *combo)
{
	int i, last_idx;

	for (i = combo->combo_size - 1; i >= 0; i--) {
		last_idx = combo->src_size - combo->combo_size + i;
		if (combo->indices[i] != last_idx) {
			combo->indices[i] += 1;
			return i;
		}
	}

	/* should never reach here but returning to make the compiler happy */
	assert(0);
	return combo->combo_size;
}

/*
 * See the comments above txh_combo_next for an explanation of this function.
 */
static void update_indices (txh_combo_iter_t *combo)
{
	int i, next_idx;

	if (combo->indices[0] == combo->src_size - combo->combo_size) {
		combo->done_flag = 1;
		return;
	}

	next_idx = increment_next_index(combo);
	for (i = next_idx + 1; i < combo->combo_size; i++) {
		combo->indices[i] = combo->indices[i - 1] + 1;
	}
}

/*
 * Each call to txh_combo_next iterates through one more combination of cards
 * initialized by txh_combo_init.  The basic algorithm works like this:  Say
 * we have a set of integers given by:
 *
 *     [0, 1, 2, 3, 4, 5, 6]
 *
 * and we wanted to enumerate all 3-integer combinations of the set.  Our
 * algorithm starts with [0, 1, 2] -- the first three integers.  It then
 * increments the last integer in the set so that now we have [0, 1, 3].  This
 * continues until we reach the end ([0, 1, 6]).  When we can no longer
 * increment the last integer, we step down to the next integer and increment
 * it.  After we do this we move all higher integers so that they are
 * consecutive with the integer we incremented.  For example, the next combo
 * after [0, 1, 6] is [0, 2, 3], and the next after [0, 5, 6] is [1, 2, 3].
 *
 * See http://en.wikipedia.org/wiki/Combination#Number_of_k-combinations for a
 * better visual of the algorithm.
 */
int txh_combo_next (txh_combo_iter_t *combo)
{
	if (combo->done_flag) {
		return 0;
	}
	set_combo_array(combo);
	update_indices(combo);
	return 1;
}

txh_card_t *txh_combo_get_cards (txh_combo_iter_t *combo)
{
	return combo->combo;
}

void txh_combo_free (txh_combo_iter_t *combo)
{
	free(combo->src);
}

/*
 * Calculates the result of C(n, k), "n choose k", to determine how many
 * combinations of k items can be made from a set of n items:
 *
 *                          n!
 *                     -----------
 *                     k! (n - k)!
 */
unsigned int txh_num_combinations (unsigned int n, unsigned int k)
{
	uint64_t i, low, high, numerator, denominator;

	if (k > n) {
		return 0;
	}

	if (n - k > k) {
		high = n - k;
		low = k;
	} else {
		high = k;
		low = n - k;
	}

	numerator = 1;
	for (i = high + 1; i <= n; i++) {
		numerator *= i;
	}

	denominator = 1;
	for (i = 2; i <= low; i++) {
		denominator *= i;
	}
	return (unsigned int)(numerator / denominator);
}

