#ifndef _RB_CATCH_
#define _RB_CATCH_

#include <ruby.h>
#include <stdio.h>
#include <stdlib.h>

#define RB_CATCH(rb_func, ...)                                                 \
	({                                                                     \
	 	VALUE __ret;                                                   \
		int __err = 0;                                                 \
		VALUE __local_ ## rb_func (VALUE dummy)                        \
		{                                                              \
			return rb_func(__VA_ARGS__);                           \
		}                                                              \
		__ret = rb_protect(__local_ ## rb_func, 0, &__err);            \
	 	if (__err) {                                                   \
	 		char *__class, *__msg;                                 \
	 		VALUE __err = rb_gv_get("$!");                         \
	 		__class = RSTRING_PTR(rb_class_path(CLASS_OF(__err))); \
	 		__msg = RSTRING_PTR(rb_obj_as_string(__err));          \
	 		fprintf(stderr, "%s() in %s +%d caught '%s': %s\n",    \
				__FUNCTION__, __FILE__, __LINE__,              \
				__class, __msg);                               \
	 		exit(1);                                               \
	 	}                                                              \
	 	__ret;                                                         \
	})

#endif
