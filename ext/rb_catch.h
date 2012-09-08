#ifndef _RB_CATCH_
#define _RB_CATCH_

#include <ruby.h>
#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

/*
 * WARNING: Due to the use of nested C functions, this macro is unlikely to
 * compile with anything other than GCC.
 *
 * The RB_CATCH() macro wraps calls to the ruby VM libraries in order to handle
 * any uncaught exceptions.  The code will log the uncaught exception and then
 * force an exit with a return value of 1.  If calling the ruby function
 * resulted in no exceptions, then the result of the call to "rb_func" (a ruby
 * VALUE type) is returned.
 *
 * Ruby functions that are eligible to be wrapped by the RB_CATCH() macro are
 * functions which take at least one argument and return a VALUE type.
 *
 * The code below assumes that openlog() has already been invoked.
 */
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
	 		syslog(LOG_ERR, "%s() in %s +%d caught '%s': %s\n",    \
				__FUNCTION__, __FILE__, __LINE__,              \
				__class, __msg);                               \
	 		exit(1);                                               \
	 	}                                                              \
	 	__ret;                                                         \
	})

#endif
