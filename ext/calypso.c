#include <assert.h>
#include <errno.h>
#include <fuse.h>
#include <ruby.h>

#include "calypso.h"


VALUE Calypso, Calypso_FS;

#define GET_CALYPSO_FS_REF() rb_funcall(Calypso_FS, rb_intern("instance"), 0)

#define CFS_METHOD(func, ...) \
	rb_funcall(GET_CALYPSO_FS_REF(), rb_intern( #func ), __VA_ARGS__)


int calypso_getattr (const char *path, struct stat *stbuf)
{
	VALUE size;

	memset(stbuf, 0, sizeof(*stbuf));
	if (strcmp(path, "/") == 0) {
		stbuf->st_mode = S_IFDIR | 0755;
		stbuf->st_nlink = 2;

	} else {
		size = CFS_METHOD(get_size, 1, rb_str_new_cstr(path));
		if (NIL_P(size)) {
			return -ENOENT;
		}
		stbuf->st_size = FIX2INT(size);
		stbuf->st_mode = S_IFREG | 0644;
		stbuf->st_nlink = 1;
	}
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
	CFS_METHOD(create, 1, rb_str_new_cstr(path));
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

int calypso_utimens (const char *path, const struct timespec tv[2])
{
	/* TODO */
	return 0;
}
