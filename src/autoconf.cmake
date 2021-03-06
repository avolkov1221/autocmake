#=============================================================================
# Copyright 2010-2012 Andrey Volkov <avolkov@volklog.org>.
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING3.  If not see
# <http://www.gnu.org/licenses/>.
#
# AC_XXX macroses library for simplify autoconf scripts porting
#

include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CheckFunctionExists)

macro(AC_INIT package version)
# bug-report tarname url)
	project(${package})
	set(AC_PACKAGE_NAME "${package}")
	set(PACKAGE_NAME AC_PACKAGE_NAME)

	set(AC_PACKAGE_VERSION "${version}")
	set(PACKAGE_VERSION	"${version}")
	set(VERSION	"${version}")
	
	if(${ARGC} GREATER 2)
    	set(AC_PACKAGE_BUGREPORT ${argv2})
    	set(REPORT_BUGS_TO ${AC_PACKAGE_BUGREPORT})
	endif()

	if(${ARGC} GREATER 3)
    	set(AC_PACKAGE_TARNAME ${argv3})
    else()
    	set(AC_PACKAGE_TARNAME ${argv3})
	endif()

	if(${ARGC} GREATER 4)
    	set(AC_PACKAGE_URL ${argv4})
	endif()

#	Exactly �package version�.
#	AC_PACKAGE_STRING
#	PACKAGE_STRING

#   Exactly bug-report, if one was provided.
#	AC_PACKAGE_BUGREPORT
#	PACKAGE_BUGREPORT

#	AC_PACKAGE_TARNAME
#	PACKAGE_TARNAME

#  Exactly url, if one was provided.
#  If url was empty, but package begins with �GNU �,
#  then this defaults to 'http://www.gnu.org/software/tarname/',
#  otherwise, no URL is assumed.

#	AC_PACKAGE_URL
#	PACKAGE_URL
endmacro(AC_INIT)

#macro(AC_INIT)
#set(_ac_config_h_string_
#"/* config.h. Generated by cmake.  */
#")
#endmacro(AC_INIT)

function(AC_MSG_CHECKING msg)
    message(STATUS "checking ${msg}...")
endfunction(AC_MSG_CHECKING)

function(AC_MSG_WARN msg)
    message("!! ${msg}")
endfunction(AC_MSG_WARN)

function(AC_MSG_ERROR msg)
    message(FATAL_ERROR "${msg}")
endfunction(AC_MSG_ERROR)

function(AC_MSG_RESULT msg)
    message(STATUS "${msg}")
endfunction(AC_MSG_RESULT)

macro(AC_DEFINE have_var)
    if(${ARGC} EQUAL 1)
      set(val 1)
    else()
      set(val ${ARGV1})
    endif()
	if(${ARGC} EQUAL 3)
        set(_ac_config_h_string_ 
        	"${_ac_config_h_string_}\n${ARGV2}")
	endif()
    set(${have_var} ${val} CACHE INTERNAL "${ARGV2}") 
	set(_ac_config_h_string_ 
		"${_ac_config_h_string_}\n#cmakedefine ${have_var} @${have_var}@\n")
endmacro(AC_DEFINE)

macro(AC_CHECK_HEADERS)
    set(ac_cv_headers 1)
	foreach(h ${ARGV})
		string(REGEX REPLACE "[.\\/]" "_" name "${h}")
	    set(desc "/* Define to 1 if you have the <${h}> header file. */") 
		string(TOUPPER "HAVE_${name}" var)
		if(NOT DEFINED ac_cv_header_${name})
    		check_include_file(${h} ${var})
    		if(!${${var}})
    		    set(ac_cv_header_${name} 0 CACHE INTERNAL ${desc})
                unset(ac_cv_headers)
    		else()
    		    set(ac_cv_header_${name} 1 CACHE INTERNAL ${desc}) 
    		endif()
    	endif()
		if(NOT DEFINED ac_cv_header_${name}_config_h)
		    set(ac_cv_header_${name}_config_h 1)
    		if(ac_cv_header_${name})
    			AC_DEFINE(${var} 1 ${desc})
    		else()
    	        unset(${var})
    		endif()
    	endif()
	endforeach()
endmacro(AC_CHECK_HEADERS)

macro(AC_HEADER_STDC)
    if(NOT DEFINED ac_cv_header_stdc)
        message(STATUS "Checking whether system has ANSI C header files")
        AC_CHECK_HEADERS(
                "dlfcn.h"
                "stdint.h"
                "stddef.h"
                "inttypes.h"
                "stdlib.h"
                "strings.h"
                "string.h"
                "float.h")
        if(ac_cv_headers)
            # SunOS 4.x string.h does not declare mem*, contrary to ANSI.
        	check_symbol_exists(memchr "string.h" memchr_exist)
        	if(memchr_exist)
        	    # ISC 2.0.2 stdlib.h does not declare free, contrary to ANSI.
        		check_symbol_exists(free "stdlib.h" free_exist)
        		if(free_exist)
        			message(STATUS "ANSI C header files - found")
        			set(STDC_HEADERS 1 CACHE INTERNAL "System has ANSI C header files")
        		endif(free_exist)
        	endif(memchr_exist)
        endif(ac_cv_headers)
        if(NOT STDC_HEADERS)
        	message(STATUS "ANSI C header files - not found")
        	set(STDC_HEADERS 0 CACHE INTERNAL "System has NOT ANSI C header files")
        endif(NOT STDC_HEADERS)
        set(ac_cv_header_stdc ${STDC_HEADERS}) 
    endif()        
endmacro(AC_HEADER_STDC)

macro(AC_INCLUDES_DEFAULT)
    if(${ARGC} EQUAL 0)
        if(NOT DEFINED _ac_includes_default_default)
            unset(i)
            set(i "#include <stdio.h>\n"
                  "#ifdef HAVE_SYS_TYPES_H\n"
                  "# include <sys/types.h>\n"
                  "#endif\n"
                  "#ifdef HAVE_SYS_STAT_H\n"
                  "# include <sys/stat.h>\n"
                  "#endif\n"
                  "#ifdef STDC_HEADERS\n"
                  "# include <stdlib.h>\n"
                  "# include <stddef.h>\n"
                  "#else\n"
                  "# ifdef HAVE_STDLIB_H\n"
                  "#  include <stdlib.h>\n"
                  "# endif\n"
                  "#endif\n"
                  "#ifdef HAVE_STRING_H\n"
                  "# if !defined STDC_HEADERS && defined HAVE_MEMORY_H\n"
                  "#  include <memory.h>\n"
                  "# endif\n"
                  "# include <string.h>\n"
                  "#endif\n"
                  "#ifdef HAVE_STRINGS_H\n"
                  "# include <strings.h>\n"
                  "#endif\n"
                  "#ifdef HAVE_INTTYPES_H\n"
                  "# include <inttypes.h>\n"
                  "#endif\n"
                  "#ifdef HAVE_STDINT_H\n"
                  "# include <stdint.h>\n"
                  "#endif\n"
                  "#ifdef HAVE_UNISTD_H\n"
                  "# include <unistd.h>\n"
                  "#endif\n"
                 )
             foreach(f ${i})
               set(_ac_includes_default_default
                       "${_ac_includes_default_default}${f}")
             endforeach()
             AC_HEADER_STDC()
             AC_CHECK_HEADERS(
                   "sys/types.h"
                   "sys/stat.h"
                   "stdlib.h"
                   "string.h"
                   "memory.h"
                   "strings.h"
                   "inttypes.h"
                   "stdint.h"
                   "unistd.h")
        endif()                
        set(_ac_includes_default ${_ac_includes_default_default})
    else()
        set(_ac_includes_default $ARGV1)
    endif()           
endmacro()

macro(AC_TRY_COMPILE includes test_code result)
    if(NOT DEFINED ${result})
        string(CONFIGURE "${_ac_config_h_string_}" confdefs)
        CHECK_C_SOURCE_COMPILES(
            "${confdefs}
            /* end confdefs.h. */
            ${includes}
            int main () {
                ${test_code}
                ;
            return 0;
            }
            " ${result})
        if(${result})
            set(${result} 1 CACHE INTERNAL "${result}")
        else()
            set(${result} 0 CACHE INTERNAL "${result}")
        endif()
    endif()
endmacro()

macro(AC_CHECK_TYPE check_type)
    string(REPLACE " " "_" name ${check_type})
    string(REPLACE "*" "p" name ${name})

    if(NOT DEFINED ac_cv_type_${name})
        set(lst ${ARGV})
        list(REMOVE_AT lst 0)
        unset(s)
    	foreach(h ${lst})
            set(s "${s}\n${h}")
        endforeach()
    message(STATUS "AC_CHECK_TYPE (${name}): includes ${s}")
#May be AC_TRY_COMPILE("${s}" "${check_type} *d = 0" ac_cv_type_${name})?
        check_c_source_compiles("
            ${s}
            int main(int argc, char *argv[])
            {
              ${check_type} *d = 0;
              return 0;
            }" ac_cv_type_${name} )
    endif()
	if(NOT DEFINED ac_cv_type_${name}_config_h)
	    set(ac_cv_type_${name}_config_h 1)
		if(!ac_cv_type_${name})
	          unset(ac_cv_type_${name})
	          unset(acx_cv_type_${name})
		else()
			AC_DEFINE(ac_cv_type_${name} 1
			    "/* Define to 1 if you have the ${check_type} type. */")
			AC_DEFINE(acx_cv_type_${name} ${check_type}
			"/* Define to ${check_type} if you have the ${check_type} type. */")
		endif()
	endif()
endmacro(AC_CHECK_TYPE)

#AC_DEFUN([AC_CHECK_FUNCS],
#[m4_map_args_w([$1], [_AH_CHECK_FUNC(], [)])]dnl
#[AS_FOR([AC_func], [ac_func], [$1],
#[AC_CHECK_FUNC(AC_func,
#               [AC_DEFINE_UNQUOTED(AS_TR_CPP([HAVE_]AC_func)) $2],
#               [$3])dnl])
#])# AC_CHECK_FUNCS
macro(AC_CHECK_FUNCS)
    foreach(f ${ARGV})
        string(TOUPPER "HAVE_${f}" var)
        if(NOT DEFINED ${var})
            check_function_exists("${f}" ${var})
        endif()
        if(NOT DEFINED ${var}_config_h)
            set(${var}_config_h 1)
            if(${var})
    			AC_DEFINE(${var} 1
        			"/* Define to 1 if you have the '${f}' function. */")
            endif()
        endif()
    endforeach()
endmacro(AC_CHECK_FUNCS)

macro(AC_CHECK_DECL func)
#   as_decl_name=`echo $2|sed 's/ *(.*//'`
    string(REGEX REPLACE "^([ \t]*)(.*)([ \t]*[(].*)" "\\2" as_decl_name ${func})       
    if(NOT DEFINED ac_cv_have_decl_${as_decl_name})
        if(${ARGC} EQUAL 1)
            AC_INCLUDES_DEFAULT()
            set(includes ${_ac_includes_default})
        else()
            set(includes ${ARGV1})
        endif()

#   as_decl_use=`echo $2|sed -e 's/(/((/' -e 's/)/) 0&/' -e 's/,/) 0& (/g'`
        string(REPLACE "(" "((" as_decl_use ${func})
        string(REPLACE ")" ") 0)" as_decl_use ${as_decl_use})
        string(REPLACE "," ") 0, (" as_decl_use ${as_decl_use})

        AC_TRY_COMPILE("${includes}"
"
                #ifndef ${as_decl_name}
                #    ifdef __cplusplus
                        (void) ${as_decl_use};
                #    else
                        (void) ${as_decl_name};
                #    endif
                #endif
"        
         ac_cv_have_decl_${as_decl_name})
    endif()
endmacro(AC_CHECK_DECL)

macro(AC_CHECK_DECLS funcs)
    if(${ARGC} EQUAL 1)
        AC_INCLUDES_DEFAULT()
        set(includes ${_ac_includes_default})
    else()
        set(includes ${ARGV1})
    endif()

    foreach(f ${funcs})
        string(REGEX REPLACE 
               "^([ \t]*)(.*)([ \t]*[(].*)" "\\2" name ${f})       
        string(TOUPPER "${name}" up_f)
        set(desc
"/* Define to 1 if you have the declaration of '${name}',
  * and to 0 if you don't. */")
        if(NOT DEFINED HAVE_DECL_${up_f} )
            AC_CHECK_DECL(${f} ${includes})
            set(HAVE_DECL_${up_f} 
                ${ac_cv_have_decl_${name}} CACHE INTERNAL 
                ${desc})
        endif()
        if(NOT DEFINED HAVE_DECL_${up_f}_config_h )
            set(HAVE_DECL_${up_f}_config_h 1)
           	set(_ac_config_h_string_ 
    		"${_ac_config_h_string_}\n${desc}\n#cmakedefine01 HAVE_DECL_${up_f}\n")
        endif()         
    endforeach()
endmacro(AC_CHECK_DECLS)

macro(AC_CHECK_SIZEOF check_type)
    string(REPLACE " " "_" name ${check_type})
    string(REPLACE "*" "p" name ${name})
    if(NOT DEFINED ac_cv_sizeof_${name})
        string(TOUPPER ${name} up_name)
        CHECK_TYPE_SIZE("${check_type}" SIZEOF_${up_name})
        set(desc "size of '${check_type}' is ${ac_cv_sizeof_${name}}")
        set(ac_cv_sizeof_${name} ${SIZEOF_${up_name}} CACHE INTERNAL ${desc})
        message(STATUS ${desc})
    endif()    
endmacro(AC_CHECK_SIZEOF)

include(headers)

# A function to check for zlib availability.  zlib is used by default
# unless the user configured with --disable-nls.

macro(AM_ZLIB)
  # See if the user specified whether he wants zlib support or not.
    include(FindZLIB)
    if(ZLIB_FOUND)
        set(val 1)
    else()
        set(val 0)
    endif()
    AC_DEFINE(HAVE_ZLIB_H ${val} 
              "/* Define to 1 if you have the <zlib.h> header file. */")
#  AC_ARG_WITH(zlib,
#    [  --with-zlib             include zlib support (auto/yes/no) [default=auto]],
#    [], [with_zlib=auto])

#  if test "$with_zlib" != "no"; then
#    AC_SEARCH_LIBS(zlibVersion, z, [AC_CHECK_HEADERS(zlib.h)])
#    if test "$with_zlib" = "yes" -a "$ac_cv_header_zlib_h" != "yes"; then
#      AC_MSG_ERROR([zlib (libz) library was explicitly requested but not found])
#    fi
#  fi
endmacro(AM_ZLIB)

## ----------------------------------- ##
## Getting the canonical system type.  ##
## ----------------------------------- ##

# The inputs are:
#    cmake -Dhost=HOST -Dtarget=TARGET -Dbuild=BUILD
#
# The rules are:
# 1. Build defaults to the current platform, as determined by config.guess.
# 2. Host defaults to build.
# 3. Target defaults to host.


# _AC_CANONICAL_SPLIT(THING)
# --------------------------
# Generate the variables THING, THING_{alias cpu vendor os}.
macro(_AC_CANONICAL_SPLIT thing)
endmacro(_AC_CANONICAL_SPLIT)

#m4_define([_AC_CANONICAL_SPLIT],
#[case $ac_cv_$1 in
#*-*-*) ;;
#*) AC_MSG_ERROR([invalid value of canonical $1]);;
#esac
#AC_SUBST([$1], [$ac_cv_$1])dnl
#ac_save_IFS=$IFS; IFS='-'
#set x $ac_cv_$1
#shift
#AC_SUBST([$1_cpu], [$[1]])dnl
#AC_SUBST([$1_vendor], [$[2]])dnl
#shift; shift
#[# Remember, the first character of IFS is used to create $]*,
## except with old shells:
#$1_os=$[*]
#IFS=$ac_save_IFS
#case $$1_os in *\ *) $1_os=`echo "$$1_os" | sed 's/ /-/g'`;; esac
#AC_SUBST([$1_os])dnl
#])# _AC_CANONICAL_SPLIT

# AC_CANONICAL_TARGET
# -------------------
macro(AC_CANONICAL_TARGET)
endmacro(AC_CANONICAL_TARGET)
# AC_CANONICAL_TARGET
