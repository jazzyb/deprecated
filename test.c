#include <ruby.h>
#include <stdio.h>

VALUE instance_wrap (VALUE Calypso_FS)
{
	return rb_funcall(Calypso_FS, rb_intern("xxxxxxx"), 0);
}

int main (int argc, char **argv)
{
	int error;
	VALUE Calypso, Calypso_FS, obj;

	printf("%d\n", sizeof(VALUE));
	ruby_init();
	ruby_init_loadpath();
	rb_require("./lib/calypso");
	Calypso = rb_const_get(rb_cObject, rb_intern("Calypso"));
	Calypso_FS = rb_const_get(Calypso, rb_intern("FS"));
	obj = rb_protect(instance_wrap, Calypso_FS, &error);
	if (error) {
		VALUE err_class;
		VALUE err = rb_gv_get("$!");
		err_class = rb_class_path(CLASS_OF(err));
		printf("%s: %s\n", RSTRING_PTR(err_class), RSTRING_PTR(rb_obj_as_string(err)));
	}
	printf("obj is %s\n", NIL_P(obj) ? "NIL" : "!NIL");
	return 0;
}
