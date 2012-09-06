#ifndef _CALYPSO_H_
#define _CALYPSO_H_

#include <fuse.h>
#include <ruby.h>

extern VALUE Calypso, Calypso_FS;

int calypso_getattr (const char *path, struct stat *stbuf);
int calypso_readdir (const char *path, void *buf, fuse_fill_dir_t filler,
		off_t offset, struct fuse_file_info *fi);
int calypso_create (const char *path, mode_t mode, struct fuse_file_info *fi);
int calypso_open (const char *path, struct fuse_file_info *fi);
int calypso_read (const char *path, char *buf, size_t size, off_t offset,
		struct fuse_file_info *fi);
int calypso_write (const char *path, const char *buf, size_t size, off_t offset,
		struct fuse_file_info *fi);
int calypso_truncate (const char *path, off_t offset);
int calypso_unlink (const char *path);
int calypso_utimens (const char *path, const struct timespec tv[2]);
int calypso_chown (const char *path, uid_t uid, gid_t gid);
int calypso_chmod (const char *path, mode_t mode);

#endif
