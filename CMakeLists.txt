cmake_minimum_required(VERSION 3.9.1)
project(libmpeg2 C CXX)

if(NOT DEFINED SYSTEM_NAME)
  set(SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
endif()

if(NOT DEFINED SYSTEM_PROCESSOR)
  set(SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

if(NOT "${SYSTEM_NAME}" STREQUAL "Darwin")
  enable_language(ASM)
endif()

set(MPEG2_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
set(MPEG2_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}")

if("${MPEG2_ROOT}" STREQUAL "${MPEG2_CONFIG_DIR}")
  message(
    FATAL_ERROR
      "Building from within the libmpeg2 source tree is not supported.\n"
      "Hint: Run these commands\n"
      "$ rm -rf CMakeCache.txt CMakeFiles\n"
      "$ mkdir -p ./build\n"
      "$ cd ./build\n"
      "And re-run CMake from the build directory.")
endif()

if("${SYSTEM_NAME}" STREQUAL "Android")
    find_library(log-lib log QUIET)
    if(NOT log-lib)
      message(FATAL_ERROR "Could NOT find log library, retry after installing \
                           log library at sysroot.")
    else()
      message(STATUS "Found log-lib: ${log-lib}")
    endif()
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
set(CMAKE_STATIC_LIBRARY_PREFIX "")

include("${MPEG2_ROOT}/cmake/utils.cmake")
libmpeg2_add_compile_options()
libmpeg2_add_definitions()
libmpeg2_set_link_libraries()

list(APPEND LIBMPEG2DEC_SRCS
            "${MPEG2_ROOT}/common/impeg2_buf_mgr.c"
            "${MPEG2_ROOT}/common/impeg2_disp_mgr.c"
            "${MPEG2_ROOT}/common/impeg2_format_conv.c"
            "${MPEG2_ROOT}/common/impeg2_globals.c"
            "${MPEG2_ROOT}/common/impeg2_idct.c"
            "${MPEG2_ROOT}/common/impeg2_inter_pred.c"
            "${MPEG2_ROOT}/common/impeg2_job_queue.c"
            "${MPEG2_ROOT}/common/impeg2_mem_func.c"
            "${MPEG2_ROOT}/common/ithread.c"
            "${MPEG2_ROOT}/decoder/impeg2d_api_main.c"
            "${MPEG2_ROOT}/decoder/impeg2d_bitstream.c"
            "${MPEG2_ROOT}/decoder/impeg2d_debug.c"
            "${MPEG2_ROOT}/decoder/impeg2d_dec_hdr.c"
            "${MPEG2_ROOT}/decoder/impeg2d_decoder.c"
            "${MPEG2_ROOT}/decoder/impeg2d_d_pic.c"
            "${MPEG2_ROOT}/decoder/impeg2d_function_selector_generic.c"
            "${MPEG2_ROOT}/decoder/impeg2d_globals.c"
            "${MPEG2_ROOT}/decoder/impeg2d_i_pic.c"
            "${MPEG2_ROOT}/decoder/impeg2d_mc.c"
            "${MPEG2_ROOT}/decoder/impeg2d_mv_dec.c"
            "${MPEG2_ROOT}/decoder/impeg2d_pic_proc.c"
            "${MPEG2_ROOT}/decoder/impeg2d_pnb_pic.c"
            "${MPEG2_ROOT}/decoder/impeg2d_vld.c"
            "${MPEG2_ROOT}/decoder/impeg2d_vld_tables.c"
            "${MPEG2_ROOT}/decoder/impeg2d_deinterlace.c"
            "${MPEG2_ROOT}/common/icv_sad.c"
            "${MPEG2_ROOT}/common/icv_variance.c"
            "${MPEG2_ROOT}/common/ideint.c"
            "${MPEG2_ROOT}/common/ideint_cac.c"
            "${MPEG2_ROOT}/common/ideint_debug.c"
            "${MPEG2_ROOT}/common/ideint_function_selector_generic.c"
            "${MPEG2_ROOT}/common/ideint_utils.c")

include_directories(${MPEG2_ROOT}/common)
include_directories(${MPEG2_ROOT}/decoder)

if("${SYSTEM_PROCESSOR}" STREQUAL "aarch64" OR "${SYSTEM_PROCESSOR}" STREQUAL "arm64")
  list(APPEND LIBMPEG2DEC_SRCS
            "${MPEG2_ROOT}/common/arm/ideint_function_selector.c"
            "${MPEG2_ROOT}/common/arm/ideint_function_selector_av8.c"
            "${MPEG2_ROOT}/common/armv8/icv_sad_av8.s"
            "${MPEG2_ROOT}/common/armv8/icv_variance_av8.s"
            "${MPEG2_ROOT}/common/armv8/ideint_cac_av8.s"
            "${MPEG2_ROOT}/common/armv8/ideint_spatial_filter_av8.s"
            "${MPEG2_ROOT}/common/armv8/impeg2_format_conv.s"
            "${MPEG2_ROOT}/common/armv8/impeg2_idct.s"
            "${MPEG2_ROOT}/common/armv8/impeg2_inter_pred.s"
            "${MPEG2_ROOT}/common/armv8/impeg2_mem_func.s"
            "${MPEG2_ROOT}/common/armv8/impeg2_neon_macros.s"
            "${MPEG2_ROOT}/decoder/arm/impeg2d_function_selector.c"
            "${MPEG2_ROOT}/decoder/arm/impeg2d_function_selector_av8.c")
  include_directories(${MPEG2_ROOT}/common/armv8)
  include_directories(${MPEG2_ROOT}/common/arm)

elseif("${SYSTEM_PROCESSOR}" STREQUAL "aarch32")
  list(APPEND LIBMPEG2DEC_SRCS
                "${MPEG2_ROOT}/common/arm/ideint_function_selector.c"
                "${MPEG2_ROOT}/decoder/arm/impeg2d_function_selector.c"
                "${MPEG2_ROOT}/common/arm/icv_sad_a9.s"
                "${MPEG2_ROOT}/common/arm/icv_variance_a9.s"
                "${MPEG2_ROOT}/common/arm/ideint_cac_a9.s"
                "${MPEG2_ROOT}/common/arm/ideint_function_selector_a9.c"
                "${MPEG2_ROOT}/common/arm/ideint_spatial_filter_a9.s"
                "${MPEG2_ROOT}/common/arm/impeg2_format_conv.s"
                "${MPEG2_ROOT}/common/arm/impeg2_idct.s"
                "${MPEG2_ROOT}/common/arm/impeg2_inter_pred.s"
                "${MPEG2_ROOT}/common/arm/impeg2_mem_func.s"
                "${MPEG2_ROOT}/decoder/arm/impeg2d_function_selector_a9q.c")

  include_directories(${MPEG2_ROOT}/common/arm)
  include_directories(${MPEG2_ROOT}/decoder/arm)

else()
  list(APPEND LIBMPEG2DEC_SRCS
                "${MPEG2_ROOT}/common/x86/icv_sad_ssse3.c"
                "${MPEG2_ROOT}/common/x86/icv_variance_ssse3.c"
                "${MPEG2_ROOT}/common/x86/ideint_cac_ssse3.c"
                "${MPEG2_ROOT}/common/x86/ideint_function_selector.c"
                "${MPEG2_ROOT}/common/x86/ideint_function_selector_sse42.c"
                "${MPEG2_ROOT}/common/x86/ideint_function_selector_ssse3.c"
                "${MPEG2_ROOT}/common/x86/ideint_spatial_filter_ssse3.c"
                "${MPEG2_ROOT}/common/x86/impeg2_idct_recon_sse42_intr.c"
                "${MPEG2_ROOT}/common/x86/impeg2_inter_pred_sse42_intr.c"
                "${MPEG2_ROOT}/common/x86/impeg2_mem_func_sse42_intr.c"
                "${MPEG2_ROOT}/decoder/x86/impeg2d_function_selector.c"
                "${MPEG2_ROOT}/decoder/x86/impeg2d_function_selector_avx2.c"
                "${MPEG2_ROOT}/decoder/x86/impeg2d_function_selector_sse42.c"
                "${MPEG2_ROOT}/decoder/x86/impeg2d_function_selector_ssse3.c")

  include_directories(${MPEG2_ROOT}/common/x86)
  include_directories(${MPEG2_ROOT}/decoder/x86)
  set(LIBMPEG2DEC_C_FLAGS "${LIBMPEG2DEC_X86_C_FLAGS}")

endif()

include_directories(${LIBMPEG2DEC_INCLUDES})

add_library(libmpeg2dec ${LIBMPEG2DEC_SRCS})

set_target_properties(libmpeg2dec
                      PROPERTIES COMPILE_FLAGS "${LIBMPEG2DEC_C_FLAGS}")

libmpeg2_add_executable(mpeg2dec libmpeg2dec SOURCES ${MPEG2_ROOT}/test/decoder/main.c)
target_compile_definitions(mpeg2dec PRIVATE PROFILE_ENABLE MD5_DISABLE)

if(NOT "${SYSTEM_NAME}" STREQUAL "Darwin")
  libmpeg2_add_fuzzer(mpeg2_dec_fuzzer libmpeg2dec SOURCES ${MPEG2_ROOT}/fuzzer/mpeg2_dec_fuzzer.cpp)
endif()
