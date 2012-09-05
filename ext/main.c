#include <assert.h>
#include <errno.h>
#include <fuse.h>
#include <getopt.h>
#include <ruby.h>
#include <syslog.h>

#include "calypso.h"
#include "rb_catch.h"


static void init_logging (const char *id)
{
	openlog(id, LOG_ODELAY, LOG_USER);
}

static void load_cwd_lib (void)
{
	VALUE load_path = rb_gv_get("$:");
	rb_ary_push(load_path, rb_str_new_cstr("./lib"));
}

static void init_ruby_vm (const char *id)
{
	ruby_init();
	load_cwd_lib(); /* TODO remove this once we can install with gem */
	ruby_init_loadpath();
	ruby_script(id);
	RB_CATCH( rb_require, "calypso" );
	Calypso = RB_CATCH( rb_const_get, rb_cObject, rb_intern("Calypso") );
	Calypso_FS = RB_CATCH( rb_const_get, Calypso, rb_intern("FS") );
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

	init_logging(argv[0]);
	init_ruby_vm(argv[0]);

	return fuse_main(argc, argv, &calypso_oper, NULL);
}
