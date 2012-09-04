#include <assert.h>
#include <errno.h>
#include <fuse.h>
#include <getopt.h>
#include <ruby.h>

#include "calypso.h"


#if 0
static VALUE test_require (VALUE dummy)
{
	return rb_const_get(Calypso, rb_intern("FS"));
}
#endif

static void load_cwd_lib (void)
{
	VALUE lib, load_path;

	lib = rb_str_new_cstr("./lib");
	load_path = rb_gv_get("$:");
	rb_ary_push(load_path, lib);
}

static void init_ruby_vm (void)
{
	ruby_init();
	load_cwd_lib(); /* TODO remove this once we can install with gem */
	ruby_init_loadpath();
	rb_require("calypso");
	Calypso = rb_const_get(rb_cObject, rb_intern("Calypso"));
	Calypso_FS = rb_const_get(Calypso, rb_intern("FS"));
#if 0
	Calypso_FS = rb_protect(test_require, 0, &error);
	if (error) {
		VALUE err_class;
		VALUE err = rb_gv_get("$!");
		err_class = rb_class_path(CLASS_OF(err));
		printf("%s: %s\n", RSTRING_PTR(err_class), RSTRING_PTR(rb_obj_as_string(err)));
	}
#endif
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
