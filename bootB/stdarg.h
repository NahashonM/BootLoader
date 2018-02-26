#ifndef _STDARG_H
#define _STDARG_H

typedef __builtin_va_list __gnuc_va_list;

/* Define the standard macros for the user,
   if this invocation was from the user program.  */
   
#define va_start(v,l)	__builtin_va_start(v,l)
#define va_end(v)	__builtin_va_end(v)
#define va_arg(v,l)	__builtin_va_arg(v,l)
#if !defined(__STRICT_ANSI__) || __STDC_VERSION__ + 0 >= 199900L \
    || __cplusplus + 0 >= 201103L
#define va_copy(d,s)	__builtin_va_copy(d,s)
#endif
#define __va_copy(d,s)	__builtin_va_copy(d,s)


typedef __gnuc_va_list va_list;

#endif /* _STDARG_H */
