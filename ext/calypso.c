#include <assert.h>
#include <errno.h>
#include <fuse.h>
#include <ruby.h>
#include <unistd.h>

#include "calypso.h"
#include "rb_catch.h"


VALUE Calypso, Calypso_FS;

#define GET_CALYPSO_FS_REF() \
	RB_CATCH( rb_funcall, Calypso_FS, rb_intern("instance"), 0 )

#define CFS_METHOD(func, ...) \
	RB_CATCH( rb_funcall, GET_CALYPSO_FS_REF(), rb_intern( #func ), \
			__VA_ARGS__ )


int calypso_getattr (const char *path, struct stat *stbuf)
{
	VALUE attrs, val;

	memset(stbuf, 0, sizeof(*stbuf));
	if (strcmp(path, "/") == 0) {
		/* FIXME give bullshit answers for top level */
		stbuf->st_uid = getuid();
		stbuf->st_gid = getgid();
		stbuf->st_mode = S_IFDIR | 0711;
		stbuf->st_nlink = 2;
		return 0;
	}

	attrs = CFS_METHOD(getattr, 1, rb_str_new_cstr(path));
	if (NIL_P(attrs)) {
		return -ENOENT;
	}
	/* user id */
	val = RB_CATCH( rb_funcall, attrs, rb_intern("uid"), 0 );
	stbuf->st_uid = FIX2INT(val);
	/* group id */
	val = RB_CATCH( rb_funcall, attrs, rb_intern("gid"), 0 );
	stbuf->st_gid = FIX2INT(val);
	/* file permissions */
	val = RB_CATCH( rb_funcall, attrs, rb_intern("mode"), 0 );
	stbuf->st_mode = S_IFREG | FIX2INT(val);
	/* modified times */
	val = RB_CATCH( rb_funcall, attrs, rb_intern("mtime"), 0 );
	stbuf->st_atime = stbuf->st_ctime = stbuf->st_mtime = NUM2INT(val);
	/* file size */
	val = CFS_METHOD(get_size, 1, rb_str_new_cstr(path));
	stbuf->st_size = NUM2INT(val);

	stbuf->st_nlink = 1;
	return 0;
}

int calypso_readdir (const char *path, void *buf, fuse_fill_dir_t filler,
		off_t offset, struct fuse_file_info *fi)
{
	long i;
	VALUE array, str;

	filler(buf, ".", NULL, 0);
	filler(buf, "..", NULL, 0);
	array = CFS_METHOD(readdir, 1, rb_str_new_cstr(path));
	for (i = 0; i < RARRAY_LEN(array); i++) {
		str = rb_ary_entry(array, i);
		filler(buf, RSTRING_PTR(str), NULL, 0);
	}
	return 0;
}

int calypso_create (const char *path, mode_t mode, struct fuse_file_info *fi)
{
	CFS_METHOD(create, 2, rb_str_new_cstr(path), INT2FIX(mode));
	return 0;
}

int calypso_open (const char *path, struct fuse_file_info *fi)
{
	VALUE rc;

	rc = CFS_METHOD(open, 1, rb_str_new_cstr(path));
	if (NIL_P(rc)) {
		return -ENOENT;
	}
	return 0;
}

int calypso_read (const char *path, char *buf, size_t size, off_t offset,
		struct fuse_file_info *fi)
{
	VALUE str;

	str = CFS_METHOD(read, 3, rb_str_new_cstr(path), INT2NUM(size),
			INT2NUM(offset));
	memcpy(buf, RSTRING_PTR(str), size);

	return size;
}

int calypso_write (const char *path, const char *buf, size_t size, off_t offset,
		struct fuse_file_info *fi)
{
	VALUE ret;

	ret = CFS_METHOD(write, 4, rb_str_new_cstr(path), rb_str_new(buf, size),
			INT2NUM(size), INT2NUM(offset));
	return FIX2INT(ret);
}

int calypso_truncate (const char *path, off_t offset)
{
	VALUE ret;

	ret = CFS_METHOD(truncate, 2, rb_str_new_cstr(path), INT2NUM(offset));

	return FIX2INT(ret);
}

int calypso_unlink (const char *path)
{
	VALUE ret;

	ret = CFS_METHOD(unlink, 1, rb_str_new_cstr(path));
	if (NIL_P(ret)) {
		return -ENOENT;
	}
	return 0;
}

int calypso_utimens (const char *path, const struct timespec tv[2])
{
	if (tv == NULL || tv[1].tv_nsec == UTIME_NOW) {
		CFS_METHOD(utime, 1, rb_str_new_cstr(path));
	} else {
		CFS_METHOD(utime, 2, rb_str_new_cstr(path),
				INT2NUM(tv[0].tv_sec));
	}
	return 0;
}

int calypso_chown (const char *path, uid_t uid, gid_t gid)
{
	CFS_METHOD(chown, 3, rb_str_new_cstr(path), INT2FIX(uid), INT2FIX(gid));
	return 0;
}

int calypso_chmod (const char *path, mode_t mode)
{
	CFS_METHOD(chmod, 2, rb_str_new_cstr(path), INT2FIX(mode));
	return 0;
}
