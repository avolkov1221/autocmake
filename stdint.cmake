#=============================================================================
# Converted for CMake by Andrey Volkov <avolkov1221@gmail.com>.
#
# @synopsis GCC_HEADER_STDINT [( HEADER-TO-GENERATE [, HEADERS-TO-CHECK])]
#
# the "ISO C9X: 7.18 Integer types <stdint.h>" section requires the
# existence of an include file <stdint.h> that defines a set of
# typedefs, especially uint8_t,int32_t,uintptr_t.
# Many older installations will not provide this file, but some will
# have the very same definitions in <inttypes.h>. In other enviroments
# we can use the inet-types in <sys/types.h> which would define the
# typedefs int8_t and u_int8_t respectivly.
#
# This macros will create a local "_stdint.h" or the headerfile given as
# an argument. In many cases that file will pick the definition from a
# "#include <stdint.h>" or "#include <inttypes.h>" statement, while
# in other environments it will provide the set of basic 'stdint's defined:
# int8_t,uint8_t,int16_t,uint16_t,int32_t,uint32_t,intptr_t,uintptr_t
# int_least32_t.. int_fast32_t.. intmax_t
# which may or may not rely on the definitions of other files.
#
# Sometimes the stdint.h or inttypes.h headers conflict with sys/types.h,
# so we test the headers together with sys/types.h and always include it
# into the generated header (to match the tests with the generated file).
# Hopefully this is not a big annoyance.
#
# If your installed header files require the stdint-types you will want to
# create an installable file mylib-int.h that all your other installable
# header may include. So, for a library package named "mylib", just use
#      GCC_HEADER_STDINT(mylib-int.h)
# in configure.in and install that header file in Makefile.am along with
# the other headers (mylib.h).  The mylib-specific headers can simply
# use "#include <mylib-int.h>" to obtain the stdint-types.
#
# Remember, if the system already had a valid <stdint.h>, the generated
# file will include it directly. No need for fuzzy HAVE_STDINT_H things...
#
# @author  Guido Draheim <guidod@gmx.de>, Paolo Bonzini <bonzini@gnu.org>

macro(GCC_HEADER_STDINT)
    if(${ARGC} EQUAL 0)
        set(_GCC_STDINT_H "_stdint.h")
    else()
        set(_GCC_STDINT_H ${ARGV0})
    endif()

#   inttype_headers=`echo inttypes.h sys/inttypes.h $2 | sed -e 's/,/ /g'`
    if(${ARGC} GREATER 1)
        list(REMOVE_AT ARGV 1) 
        set(inttype_headers inttypes.h sys/inttypes.h)
        foreach(hdr ${ARGV})
            set(inttype_headers ${inttype_headers} ${hdr})
        endforeach()
    endif()

    set(acx_cv_header_stdint "stddef.h")
    set(acx_cv_header_stdint_kind "(already complete)")

    foreach(i stdint.h ${inttype_headers})
        unset(ac_cv_type_uintptr_t)
        unset(ac_cv_type_uintmax_t)
        unset(ac_cv_type_int_least32_t)
        unset(ac_cv_type_int_fast32_t)
        unset(ac_cv_type_uint64_t)
        message(STATUS "looking for a compliant stdint.h in ${i}")
        
        AC_CHECK_TYPE(uintmax_t
                      "#include <sys/types.h>"
                      "#include <${i}>")
        if(ac_cv_type_uintmax_t)
            set(acx_cv_header_stdint ${i})
            AC_CHECK_TYPE(uintptr_t
                            "#include <sys/types.h>"
                            "#include {$i}")
            if(NOT ac_cv_type_uintptr_t)
                set(acx_cv_header_stdint_kind "(mostly complete)")
            endif() 
            
            AC_CHECK_TYPE(int_least32_t
                            "#include <sys/types.h>"
                            "#include <${i}>")
            if(NOT ac_cv_type_int_least32_t)
                set(acx_cv_header_stdint_kind "(mostly complete)")
            endif() 
            
            AC_CHECK_TYPE(int_fast32_t
                            "#include <sys/types.h>"
                            "#include <${i}>")
            if(NOT ac_cv_type_int_fast32_t)
                set(acx_cv_header_stdint_kind "(mostly complete)")
            endif() 
            
            AC_CHECK_TYPE(uint64_t
                            "#include <sys/types.h>"
                            "#include <${i}>")
            if(NOT ac_cv_type_uint64_t)
                set(acx_cv_header_stdint_kind "(lacks uint64_t)")
            endif()
            break()
        endif()
    endforeach()
    
    if("${acx_cv_header_stdint}" MATCHES "stddef.h")
        set(acx_cv_header_stdint_kind "(lacks uintmax_t)")
        foreach(i in stdint.h ${inttype_headers})
            unset(ac_cv_type_uintptr_t)
            unset(ac_cv_type_uint32_t)
            unset(ac_cv_type_uint64_t)
            message(STATUS "looking for an incomplete stdint.h in ${i}")
            AC_CHECK_TYPE(uint32_t 
                          "#include <sys/types.h>"
                          "#include <${i}>")
            if(ac_cv_type_uint32_t)
                set(acx_cv_header_stdint ${i})            
                AC_CHECK_TYPE(uint64_t 
                                "#include <sys/types.h>"
                                "#include <${i}>")
                AC_CHECK_TYPE(uintptr_t 
                                "#include <sys/types.h>"
                                "#include <${i}>")
                break()
            endif()             
        endforeach()
    endif()

    if("${acx_cv_header_stdint}" MATCHES "stddef.h")
        set(acx_cv_header_stdint_kind "(u_intXX_t style)")
        foreach(i in sys/types.h $inttype_headers)
            unset(ac_cv_type_u_int32_t)
            unset(ac_cv_type_u_int64_t)
            message(STATUS "looking for u_intXX_t types in ${i}, ")
            AC_CHECK_TYPE(uint32_t 
                          "#include <sys/types.h>"
                          "#include <${i}>")
            if(ac_cv_type_uint32_t)
                set(acx_cv_header_stdint ${i})            
                AC_CHECK_TYPE(uint64_t 
                                "#include <sys/types.h>"
                                "#include <${i}>")
                break()
            endif()
        endforeach()
    endif()

    if("${acx_cv_header_stdint}" MATCHES "stddef.h")
        set(acx_cv_header_stdint_kind "(using manual detection)")
        unset(acx_cv_header_stdint)
    endif()

    if(NOT DEFINED ac_cv_type_uintptr_t OR 
        "${ac_cv_type_uintptr_t}" STREQUAL "0")
        unset(ac_cv_type_uintptr_t)
    endif()

    if(NOT DEFINED ac_cv_type_uint64_t OR "${ac_cv_type_uint64_t}" STREQUAL "0")
        unset(ac_cv_type_uint64_t)
    endif()

    if(NOT DEFINED ac_cv_type_u_int64_t OR 
        "${ac_cv_type_u_int64_t}" STREQUAL "0")
        unset(ac_cv_type_u_int64_t)
    endif()

    if(NOT DEFINED ac_cv_type_int_least32_t OR 
        "${ac_cv_type_int_least32_t}" STREQUAL "0")
        unset(ac_cv_type_int_least32_t)
    endif()

    if(NOT DEFINED ac_cv_type_int_fast32_t OR 
        "${ac_cv_type_int_fast32_t}" STREQUAL "0")
        unset(ac_cv_type_int_fast32_t)
    endif()

# ----------------- Summarize what we found so far

    AC_MSG_CHECKING("what to include in _GCC_STDINT_H")
    get_filename_component(name ${_GCC_STDINT_H} NAME)
    if("${name}" STREQUAL "stdint.h" OR
       "${name}" STREQUAL "inttypes.h")
        AC_MSG_WARN("${name}, are you sure you want it there?")
    endif()   

    AC_MSG_RESULT("${acx_cv_header_stdint} ${acx_cv_header_stdint_kind}")

# ----------------- done included file, check C basic types --------
# Lacking an uintptr_t?  Test size of void *
    if(NOT DEFINED acx_cv_header_stdint OR NOT DEFINED ac_cv_type_uintptr_t) 
        AC_CHECK_SIZEOF("void *")
    endif()
    
# Lacking an uint64_t?  Test size of long
    if(NOT DEFINED acx_cv_header_stdint OR 
       (NOT DEFINED ac_cv_type_uint64_t AND
        NOT DEFINED ac_cv_type_u_int64_t))
        AC_CHECK_SIZEOF(long)
    endif()

    if(NOT DEFINED acx_cv_header_stdint)
        # Lacking a good header?  Test size of everything and deduce all types.
        AC_CHECK_SIZEOF(int)
        AC_CHECK_SIZEOF(short)
        AC_CHECK_SIZEOF(char)

        AC_MSG_CHECKING("for type equivalent to int8_t")
        if(${ac_cv_sizeof_char} EQUAL 1)
            set(acx_cv_type_int8_t "char")
        else()
            AC_MSG_ERROR("no 8-bit type, please report a bug")
        endif()
        AC_MSG_RESULT(${acx_cv_type_int8_t})

        AC_MSG_CHECKING("for type equivalent to int16_t")
        if(${ac_cv_sizeof_int} EQUAL 2)
            set(acx_cv_type_int16_t "int")
        elseif(${ac_cv_sizeof_short} EQUAL 2)
            set(acx_cv_type_int16_t "short")
        else()
            AC_MSG_ERROR("no 16-bit type, please report a bug")
        endif()
        AC_MSG_RESULT(${acx_cv_type_int16_t})
        
        AC_MSG_CHECKING("for type equivalent to int32_t")
        if(${ac_cv_sizeof_int} EQUAL 4)
            set(acx_cv_type_int32_t "int")
        elseif(${ac_cv_sizeof_long} EQUAL 4)
            set(acx_cv_type_int32_t "long")
        else()
            AC_MSG_ERROR("no 32-bit type, please report a bug")
        endif()
        AC_MSG_RESULT(${acx_cv_type_int32_t})
        
    endif()

    # These tests are here to make the output prettier
    if(NOT DEFINED ac_cv_type_uint64_t AND
        NOT DEFINED ac_cv_type_u_int64_t)
        if(${ac_cv_sizeof_long} EQUAL 8)
            set(acx_cv_type_int64_t "long")
        endif()
        AC_MSG_CHECKING("for type equivalent to int64_t")
        AC_MSG_RESULT("\${acx_cv_type_int64_t-'using preprocessor symbols'}")
    endif()

# Now we can use the above types

    if(NOT DEFINED ac_cv_type_uintptr_t)
        AC_MSG_CHECKING("for type equivalent to intptr_t")
        if(ac_cv_sizeof_void_p EQUAL 2)
            set(acx_cv_type_intptr_t "int16_t")
        elseif(ac_cv_sizeof_void_p EQUAL 4)
            set(acx_cv_type_intptr_t "int32_t")
        elseif(ac_cv_sizeof_void_p EQUAL 8)
            set(acx_cv_type_intptr_t "int64_t")
        else()
            AC_MSG_ERROR("no equivalent for intptr_t, please report a bug")        
        endif()
        AC_MSG_RESULT("${acx_cv_type_intptr_t}")
    endif()
    
# ----------------- done all checks, emit header -------------
    if(CMAKE_COMPILER_IS_GNUCC)
      execute_process(COMMAND  ${CMAKE_C_COMPILER} --version  
                      OUTPUT_VARIABLE ver
                      OUTPUT_STRIP_TRAILING_WHITESPACE)
      string(REGEX MATCH "^.*$" ver ${ver})
      file(WRITE ${_GCC_STDINT_H} "/* generated for ${ver}\n*/\n")
    else()
      file(WRITE ${_GCC_STDINT_H} "/* generated for ${CMAKE_C_COMPILER_ID}\n*/\n")
    endif()

    file(APPEND ${_GCC_STDINT_H} 
        "\n#ifndef __GENERATED_STDINT_H__\n"
        "#define __GENERATED_STDINT_H__ 1\n\n"
        "#include <sys/types.h>\n"
    )

    if(NOT ("${acx_cv_header_stdint}" STREQUAL "stdint.h"))
      file(APPEND ${_GCC_STDINT_H} "#include <stddef.h>\n")
    endif()

    if(DEFINED acx_cv_header_stdint)
      file(APPEND ${_GCC_STDINT_H} "#include <${acx_cv_header_stdint}>\n")
    endif()
    
    file(APPEND ${_GCC_STDINT_H} 
        "/* glibc uses these symbols as guards to prevent redefinitions.  */\n"
        "#ifdef __int8_t_defined\n"
        "#define _INT8_T\n"
        "#define _INT16_T\n"
        "#define _INT32_T\n"
        "#endif\n"
        "#ifdef __uint32_t_defined\n"
        "#define _UINT32_T\n"
        "#endif\n"
    )
# ----------------- done header, emit basic int types -------------
    if(NOT DEFINED acx_cv_header_stdint)
        file(APPEND ${_GCC_STDINT_H} 
            "#ifndef _UINT8_T\n"
            "#define _UINT8_T\n"
            "typedef unsigned ${acx_cv_type_int8_t} uint8_t;\n"
            "#endif\n"
            "\n"
            "#ifndef _UINT16_T\n"
            "#define _UINT16_T\n"
            "typedef unsigned ${acx_cv_type_int16_t} uint16_t;\n"
            "#endif\n"
            "\n" 
            "#ifndef _UINT32_T\n"
            "#define _UINT32_T\n"
            "typedef unsigned ${acx_cv_type_int32_t} uint32_t;\n"
            "#endif\n"
            "\n"
            "#ifndef _INT8_T\n"
            "#define _INT8_T\n"
            "typedef ${acx_cv_type_int8_t} int8_t;\n"
            "#endif\n"
            "\n"
            "#ifndef _INT16_T\n"
            "#define _INT16_T\n"
            "typedef ${acx_cv_type_int16_t} int16_t;\n"
            "#endif\n"
            "\n"
            "#ifndef _INT32_T\n"
            "#define _INT32_T\n"
            "typedef ${acx_cv_type_int32_t} int32_t;\n"
            "#endif\n"
        )
    elseif(DEFINED ac_cv_type_u_int32_t)
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* int8_t int16_t int32_t defined by inet code, we do the u_intXX types */\n"
            "#ifndef _INT8_T\n"
            "#define _INT8_T\n"
            "#endif\n"
            "#ifndef _INT16_T\n"
            "#define _INT16_T\n"
            "#endif\n"
            "#ifndef _INT32_T\n"
            "#define _INT32_T\n"
            "#endif\n"
            "\n"
            "#ifndef _UINT8_T\n"
            "#define _UINT8_T\n"
            "typedef u_int8_t uint8_t;\n"
            "#endif\n"
            "\n"
            "#ifndef _UINT16_T\n"
            "#define _UINT16_T\n"
            "typedef u_int16_t uint16_t;\n"
            "#endif\n"
            "\n"
            "#ifndef _UINT32_T\n"
            "#define _UINT32_T\n"
            "typedef u_int32_t uint32_t;\n"
            "#endif\n"
        )
    else()         
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* Some systems have guard macros to prevent redefinitions, define them. */\n"
            "#ifndef _INT8_T\n"
            "#define _INT8_T\n"
            "#endif\n"
            "#ifndef _INT16_T\n"
            "#define _INT16_T\n"
            "#endif\n"
            "#ifndef _INT32_T\n"
            "#define _INT32_T\n"
            "#endif\n"
            "#ifndef _UINT8_T\n"
            "#define _UINT8_T\n"
            "#endif\n"
            "#ifndef _UINT16_T\n"
            "#define _UINT16_T\n"
            "#endif\n"
            "#ifndef _UINT32_T\n"
            "#define _UINT32_T\n"
            "#endif\n"
        )
    endif()

# ------------- done basic int types, emit int64_t types ------------
    if(DEFINED ac_cv_type_uint64_t)
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* system headers have good uint64_t and int64_t */\n"
            "#ifndef _INT64_T\n"
            "#define _INT64_T\n"
            "#endif\n"
            "#ifndef _UINT64_T\n"
            "#define _UINT64_T\n"
            "#endif\n"
        )
    elseif(DEFINED ac_cv_type_u_int64_t)
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* system headers have an u_int64_t (and int64_t) */\n"
            "#ifndef _INT64_T\n"
            "#define _INT64_T\n"
            "#endif\n"
            "#ifndef _UINT64_T\n"
            "#define _UINT64_T\n"
            "typedef u_int64_t uint64_t;\n"
            "#endif\n"
        )
    elseif("${acx_cv_type_int64_t}" STREQUAL "")
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* architecture has a 64-bit type, $acx_cv_type_int64_t */\n"
            "#ifndef _INT64_T\n"
            "#define _INT64_T\n"
            "typedef $acx_cv_type_int64_t int64_t;\n"
            "#endif\n"
            "#ifndef _UINT64_T\n"
            "#define _UINT64_T\n"
            "typedef unsigned $acx_cv_type_int64_t uint64_t;\n"
            "#endif\n"
        )
    else()
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* some common heuristics for int64_t, using compiler-specific tests */\n"
            "#if defined __STDC_VERSION__ && (__STDC_VERSION__-0) >= 199901L\n"
            "#ifndef _INT64_T\n"
            "#define _INT64_T\n"
            "typedef long long int64_t;\n"
            "#endif\n"
            "#ifndef _UINT64_T\n"
            "#define _UINT64_T\n"
            "typedef unsigned long long uint64_t;\n"
            "#endif\n"
            "\n"
            "#elif defined __GNUC__ && defined (__STDC__) && __STDC__-0\n"
            "/* NextStep 2.0 cc is really gcc 1.93 but it defines __GNUC__ = 2 and\n"
            "   does not implement __extension__.  But that compiler doesn't define\n"
            "   __GNUC_MINOR__.  */\n"
            "# if __GNUC__ < 2 || (__NeXT__ && !__GNUC_MINOR__)\n"
            "# define __extension__\n"
            "# endif\n"
            "\n"
            "# ifndef _INT64_T\n"
            "# define _INT64_T\n"
            "__extension__ typedef long long int64_t;\n"
            "# endif\n"
            "# ifndef _UINT64_T\n"
            "# define _UINT64_T\n"
            "__extension__ typedef unsigned long long uint64_t;\n"
            "# endif\n"
            "\n"
            "#elif !defined __STRICT_ANSI__\n"
            "# if defined _MSC_VER || defined __WATCOMC__ || defined __BORLANDC__\n"
            "\n"
            "#  ifndef _INT64_T\n"
            "#  define _INT64_T\n"
            "typedef __int64 int64_t;\n"
            "#  endif\n"
            "#  ifndef _UINT64_T\n"
            "#  define _UINT64_T\n"
            "typedef unsigned __int64 uint64_t;\n"
            "#  endif\n"
            "# endif /* compiler */\n"
            "\n"
            "#endif /* ANSI version */\n"
        )
    endif()
    
# ------------- done int64_t types, emit intptr types ------------
    if(NOT DEFINED ac_cv_type_uintptr_t)
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* Define intptr_t based on sizeof(void*) = $ac_cv_sizeof_void_p */\n"
            "typedef u${acx_cv_type_intptr_t} uintptr_t;\n"
            "typedef ${acx_cv_type_intptr_t}  intptr_t;\n"
        )
    endif()

# ------------- done intptr types, emit int_least types ------------
    if(NOT DEFINED ac_cv_type_int_least32_t)
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* Define int_least types */\n"
            "typedef int8_t     int_least8_t;\n"
            "typedef int16_t    int_least16_t;\n"
            "typedef int32_t    int_least32_t;\n"
            "#ifdef _INT64_T\n"
            "typedef int64_t    int_least64_t;\n"
            "#endif\n"
            "\n"
            "typedef uint8_t    uint_least8_t;\n"
            "typedef uint16_t   uint_least16_t;\n"
            "typedef uint32_t   uint_least32_t;\n"
            "#ifdef _UINT64_T\n"
            "typedef uint64_t   uint_least64_t;\n"
            "#endif\n"
        )
    endif()

# ------------- done intptr types, emit int_fast types ------------
    if(NOT DEFINED ac_cv_type_int_fast32_t)
    # NOTE: The following code assumes that sizeof (int) > 1.
    # Fix when strange machines are reported.
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* Define int_fast types.  short is often slow */\n"
            "typedef int8_t       int_fast8_t;\n"
            "typedef int          int_fast16_t;\n"
            "typedef int32_t      int_fast32_t;\n"
            "#ifdef _INT64_T\n"
            "typedef int64_t      int_fast64_t;\n"
            "#endif\n"
            "\n"
            "typedef uint8_t      uint_fast8_t;\n"
            "typedef unsigned int uint_fast16_t;\n"
            "typedef uint32_t     uint_fast32_t;\n"
            "#ifdef _UINT64_T\n"
            "typedef uint64_t     uint_fast64_t;\n"
            "#endif\n"
        )
    endif()

    if(NOT DEFINED ac_cv_type_uintmax_t)
        file(APPEND ${_GCC_STDINT_H} 
            "\n"
            "/* Define intmax based on what we found */\n"
            "#ifdef _INT64_T\n"
            "typedef int64_t       intmax_t;\n"
            "#else\n"
            "typedef long          intmax_t;\n"
            "#endif\n"
            "#ifdef _UINT64_T\n"
            "typedef uint64_t      uintmax_t;\n"
            "#else\n"
            "typedef unsigned long uintmax_t;\n"
            "#endif\n"
        )
    endif()
    
    file(APPEND ${_GCC_STDINT_H} 
            "#endif /* GCC_GENERATED_STDINT_H */\n"
        )
        
endmacro(GCC_HEADER_STDINT)

#GCC="$GCC"
#CC="$CC"
#acx_cv_header_stdint="$acx_cv_header_stdint"
#acx_cv_type_int8_t="$acx_cv_type_int8_t"
#acx_cv_type_int16_t="$acx_cv_type_int16_t"
#acx_cv_type_int32_t="$acx_cv_type_int32_t"
#acx_cv_type_int64_t="$acx_cv_type_int64_t"
#acx_cv_type_intptr_t="$acx_cv_type_intptr_t"
#ac_cv_type_uintmax_t="$ac_cv_type_uintmax_t"
#ac_cv_type_uintptr_t="$ac_cv_type_uintptr_t"
#ac_cv_type_uint64_t="$ac_cv_type_uint64_t"
#ac_cv_type_u_int64_t="$ac_cv_type_u_int64_t"
#ac_cv_type_u_int32_t="$ac_cv_type_u_int32_t"
#ac_cv_type_int_least32_t="$ac_cv_type_int_least32_t"
#ac_cv_type_int_fast32_t="$ac_cv_type_int_fast32_t"
#ac_cv_sizeof_void_p="$ac_cv_sizeof_void_p"



