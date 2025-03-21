include(CheckCXXCompilerFlag)
set(CMAKE_C_STANDARD 90)

# Adds compiler options for all targets
function(libmpeg2_add_compile_options)
  if(${SYSTEM_PROCESSOR} STREQUAL "aarch64" OR ${SYSTEM_PROCESSOR} STREQUAL "arm64")
    add_compile_options(-march=armv8-a)
  elseif(${SYSTEM_PROCESSOR} STREQUAL "aarch32")
    add_compile_options(-march=armv7-a -mfpu=neon)
  else()
    add_compile_options(-msse4.2 -mno-avx)
  endif()

  set(CMAKE_REQUIRED_FLAGS -fsanitize=fuzzer-no-link)
  check_cxx_compiler_flag(-fsanitize=fuzzer-no-link
                          COMPILER_HAS_SANITIZE_FUZZER)
  unset(CMAKE_REQUIRED_FLAGS)

  if(DEFINED SANITIZE)
    set(CMAKE_REQUIRED_FLAGS -fsanitize=${SANITIZE})
    check_cxx_compiler_flag(-fsanitize=${SANITIZE} COMPILER_HAS_SANITIZER)
    unset(CMAKE_REQUIRED_FLAGS)

    if(NOT COMPILER_HAS_SANITIZER)
      message(
        FATAL_ERROR "ERROR: Compiler doesn't support -fsanitize=${SANITIZE}")
      return()
    endif()
    add_compile_options(-fno-omit-frame-pointer -fsanitize=${SANITIZE})
  endif()

endfunction()

# Adds defintions for all targets
function(libmpeg2_add_definitions)
  if("${SYSTEM_NAME}" STREQUAL "Darwin")
    if(${SYSTEM_PROCESSOR} STREQUAL "arm64")
      add_definitions(-DARMV8 -DDARWIN -DDEFAULT_ARCH_ARMV8_GENERIC -DMULTICORE)
    else()
      add_definitions(-DX86 -DDARWIN -DDISABLE_AVX2
                      -DDEFAULT_ARCH=D_ARCH_X86_GENERIC -DMULTICORE)
    endif()
  elseif("${SYSTEM_PROCESSOR}" STREQUAL "aarch64")
    add_definitions(-DARMV8 -DDEFAULT_ARCH=D_ARCH_ARMV8_GENERIC -DENABLE_NEON -DMULTICORE)
  elseif("${SYSTEM_PROCESSOR}" STREQUAL "aarch32")
    add_definitions(-DARMV7 -DDEFAULT_ARCH=D_ARCH_ARM_A9Q -DENABLE_NEON -DMULTICORE)
  else()
    add_definitions(-DX86 -DX86_LINUX=1 -DDISABLE_AVX2
                    -DDEFAULT_ARCH=D_ARCH_X86_SSE42 -DMULTICORE)
  endif()
endfunction()

# Adds libraries needed for executables
function(libmpeg2_set_link_libraries)
  link_libraries(Threads::Threads m)
endfunction()

# cmake-format: off
# Adds a target for an executable
#
# Arguments:
# NAME: Name of the executatble
# LIB: Library that executable depends on
# SOURCES: Source files
#
# Optional Arguments:
# INCLUDES: Include paths
# LIBS: Additional libraries
# FUZZER: flag to specify if the target is a fuzzer binary
# cmake-format: on

function(libmpeg2_add_executable NAME LIB)
  set(multi_value_args SOURCES INCLUDES LIBS)
  set(optional_args FUZZER)
  cmake_parse_arguments(ARG "${optional_args}" "${single_value_args}"
                        "${multi_value_args}" ${ARGN})

  # Check if compiler supports -fsanitize=fuzzer. If not, skip building fuzzer
  # binary
  if(ARG_FUZZER)
    if(NOT COMPILER_HAS_SANITIZE_FUZZER)
      message("Compiler doesn't support -fsanitize=fuzzer. Skipping ${NAME}")
      return()
    endif()
  endif()

  add_executable(${NAME} ${ARG_SOURCES})
  target_include_directories(${NAME} PRIVATE ${ARG_INCLUDES})
  add_dependencies(${NAME} ${LIB} ${ARG_LIBS})

  target_link_libraries(${NAME} ${LIB} ${ARG_LIBS})
  if("${SYSTEM_NAME}" STREQUAL "Android")
    target_link_libraries(${NAME} ${log-lib})
  endif()

  if(ARG_FUZZER)
    target_compile_options(${NAME}
                           PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>)
    if(DEFINED ENV{LIB_FUZZING_ENGINE})
      set_target_properties(${NAME} PROPERTIES LINK_FLAGS
                                               $ENV{LIB_FUZZING_ENGINE})
    elseif(DEFINED SANITIZE)
      set_target_properties(${NAME} PROPERTIES LINK_FLAGS
                                               -fsanitize=fuzzer,${SANITIZE})
    else()
      set_target_properties(${NAME} PROPERTIES LINK_FLAGS -fsanitize=fuzzer)
    endif()
  else()
    if(DEFINED SANITIZE)
      set_target_properties(${NAME} PROPERTIES LINK_FLAGS
                                               -fsanitize=${SANITIZE})
    endif()
  endif()
endfunction()

# cmake-format: off
# Adds a target for a fuzzer binary
# Calls libhevc_add_executable with all arguments with FUZZER set to 1
# Arguments:
# Refer to libhevc_add_executable's arguments
# cmake-format: on

function(libmpeg2_add_fuzzer NAME LIB)
  libmpeg2_add_executable(${NAME} ${LIB} FUZZER 1 ${ARGV})
endfunction()
