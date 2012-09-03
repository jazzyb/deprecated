#include <assert.h>
#include <errno.h>
#include <fuse.h>
#include <getopt.h>
#include <ruby.h>

#include "calypso.h"


void init_ruby_vm (void)
{
	ruby_init();
	ruby_init_loadpath();
	rb_require("./lib/calypso");
	Calypso = rb_const_get(rb_cObject, rb_intern("Calypso"));
	Calypso_FS = rb_const_get(Calypso, rb_intern("FS"));
}

int main (int argc, char **argv)
{
	struct fuse_operations calypso_oper = {
		.getattr = calypso_getattr,
		.readdir = calypso_readdir,
		.create = calypso_create,
		.open = calypso_open,
		.read = calypso_read,
		.write = calypso_write,
		.utimens = calypso_utimens,
	};

	init_ruby_vm();

	return fuse_main(argc, argv, &calypso_oper, NULL);
}
