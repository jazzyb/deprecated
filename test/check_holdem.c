#include <check.h>

extern Suite *card_suite (void);

int main (int argc, char **argv)
{
	int number_failed;
	SRunner *sr = srunner_create(card_suite());
	/* uncomment the below if we need to run gdb */
	//srunner_set_fork_status(cr, CK_NOFORK);
	srunner_run_all(sr, CK_NORMAL);
	number_failed = srunner_ntests_failed(sr);
	srunner_free(sr);
	return (number_failed == 0) ? 0 : 1;
}

