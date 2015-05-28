/* include/osmscout/private/Config.h.  Generated from Config.h.in by configure.  */
/* include/osmscout/private/Config.h.in.  Generated from configure.ac by autoheader.  */

/* Support Altivec instructions */
/* #undef HAVE_ALTIVEC */

/* Support AVX (Advanced Vector Extensions) instructions */
/* #undef HAVE_AVX */

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if fseeko (and presumably ftello) exists and is declared. */
#define HAVE_FSEEKO 1

/* Define to 1 if the system has the type `int16_t'. */
#define HAVE_INT16_T 1

/* Define to 1 if the system has the type `int32_t'. */
#define HAVE_INT32_T 1

/* Define to 1 if the system has the type `int64_t'. */
#define HAVE_INT64_T 1

/* Define to 1 if the system has the type `int8_t'. */
#define HAVE_INT8_T 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if the system has the type `long long'. */
#define HAVE_LONG_LONG 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the `mmap' function. */
#define HAVE_MMAP 1

/* Support mmx instructions */
/* #undef HAVE_MMX */

/* Define to 1 if you have the `posix_fadvise' function. */
#define HAVE_POSIX_FADVISE 1

/* Define to 1 if you have the `posix_madvise' function. */
#define HAVE_POSIX_MADVISE 1

/* Support SSE (Streaming SIMD Extensions) instructions */
/* #undef HAVE_SSE */

/* Support SSE2 (Streaming SIMD Extensions 2) instructions */
/* #undef HAVE_SSE2 */

/* Support SSE3 (Streaming SIMD Extensions 3) instructions */
/* #undef HAVE_SSE3 */

/* Support SSSE4.1 (Streaming SIMD Extensions 4.1) instructions */
/* #undef HAVE_SSE4_1 */

/* Support SSSE4.2 (Streaming SIMD Extensions 4.2) instructions */
/* #undef HAVE_SSE4_2 */

/* Support SSSE3 (Supplemental Streaming SIMD Extensions 3) instructions */
/* #undef HAVE_SSSE3 */

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if the system has the type `std::wstring'. */
#define HAVE_STD__WSTRING 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
#define HAVE_SYS_TIME_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <thread> header file. */
#define HAVE_THREAD 1

/* Define to 1 if the system has the type `uint16_t'. */
#define HAVE_UINT16_T 1

/* Define to 1 if the system has the type `uint32_t'. */
#define HAVE_UINT32_T 1

/* Define to 1 if the system has the type `uint64_t'. */
#define HAVE_UINT64_T 1

/* Define to 1 if the system has the type `uint8_t'. */
#define HAVE_UINT8_T 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if the system has the type `unsigned long long'. */
#define HAVE_UNSIGNED_LONG_LONG 1

/* Define to 1 or 0, depending whether the compiler supports simple visibility
   declarations. */
#define HAVE_VISIBILITY 1

/* Define to the sub-directory in which libtool stores uninstalled libraries.
   */
#define LT_OBJDIR ".libs/"

/* libosmscout uses special gcc compiler features to export symbols */
#define OSMSCOUT_EXPORT_SYMBOLS 1

/* math function atanh(double) is available */
#define OSMSCOUT_HAVE_ATANH 1

/* standard library has support for atomic */
#define OSMSCOUT_HAVE_ATOMIC 1

/* int16_t is available */
#define OSMSCOUT_HAVE_INT16_T 1

/* int32_t is available */
#define OSMSCOUT_HAVE_INT32_T 1

/* int64_t is available */
#define OSMSCOUT_HAVE_INT64_T 1

/* int8_t is available */
#define OSMSCOUT_HAVE_INT8_T 1

/* libmarisa detected */
/* #undef OSMSCOUT_HAVE_LIB_MARISA */

/* math function log2(double) is available */
#define OSMSCOUT_HAVE_LOG2 1

/* long long is available */
#define OSMSCOUT_HAVE_LONG_LONG 1

/* math function lround(double) is available */
#define OSMSCOUT_HAVE_LROUND 1

/* standard library has support for mutex */
#define OSMSCOUT_HAVE_MUTEX 1

/* SSE2 processor extension available */
/* #undef OSMSCOUT_HAVE_SSE2 */

/* system header <stdint.h> is available */
#define OSMSCOUT_HAVE_STDINT_H 1

/* std::wstring is available */
#define OSMSCOUT_HAVE_STD_WSTRING 1

/* system header <thread> is available */
#define OSMSCOUT_HAVE_THREAD 1

/* uint16_t is available */
#define OSMSCOUT_HAVE_UINT16_T 1

/* uint32_t is available */
#define OSMSCOUT_HAVE_UINT32_T 1

/* uint64_t is available */
#define OSMSCOUT_HAVE_UINT64_T 1

/* uint8_t is available */
#define OSMSCOUT_HAVE_UINT8_T 1

/* unsigned long long is available */
#define OSMSCOUT_HAVE_ULONG_LONG 1

/* libosmscout needs to include <assert.h> */
/* #undef OSMSCOUT_REQUIRES_ASSERTH */

/* libosmscout needs to include <math.h> */
#define OSMSCOUT_REQUIRES_MATHH 1

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "tim@teulings.org"

/* Define to the full name of this package. */
#define PACKAGE_NAME "libosmscout"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "libosmscout 0.1"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "libosmscout"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "0.1"

/* The size of `wchar_t', as computed by sizeof. */
#define SIZEOF_WCHAR_T 4

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Enable large inode numbers on Mac OS X 10.5.  */
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
#define _FILE_OFFSET_BITS 64

/* Define to 1 to make fseeko visible on some hosts (e.g. glibc 2.2). */
/* #undef _LARGEFILE_SOURCE */

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */
