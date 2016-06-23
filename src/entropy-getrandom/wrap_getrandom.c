/*
   A wrapper around the getrandom system call.

   It is probably more robust to do this via C rather than calling 'syscall'
   from Ada, as the system call number may not be consistent and parsing the
   syscall.h header doesn't seem like it would be much fun.

   Note that getrandom is not used directly as a C function, because that
   won't link on AdaCore GNAT GPL 2016...

   Copyright (c) 2016, James Humphry - see LICENSE file for details

 */

#include <stddef.h>
#include <unistd.h>
#include <sys/syscall.h>

int wrap_getrandom(void *buf, size_t buflen, unsigned int flags)
{
  return (int) syscall(SYS_getrandom, buf, buflen, flags);
}
