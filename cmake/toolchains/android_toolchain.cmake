set(SYSTEM_NAME Android)
set(CMAKE_SYSTEM_NAME Android)

if(NOT ANDROID_PLATFORM)
  set(ANDROID_PLATFORM android-23)
endif()

# Choose target architecture with:
# -DANDROID_ABI={armeabi-v7a, arm64-v8a, x86, x86_64}
if(NOT ANDROID_ABI)
  set(ANDROID_ABI arm64-v8a)
endif()

if(ANDROID_ABI MATCHES "^armeabi")
  set(SYSTEM_PROCESSOR aarch32)
else()
  set(SYSTEM_PROCESSOR aarch64)
endif()

# Toolchain files don't have access to cached variables:
# https://gitlab.kitware.com/cmake/cmake/issues/16170. Set an intermediate
# environment variable when loaded the first time.
if(MPEG2_ANDROID_NDK_PATH)
  set(ENV{MPEG2_ANDROID_NDK_PATH} "${MPEG2_ANDROID_NDK_PATH}")
else()
  set(MPEG2_ANDROID_NDK_PATH "$ENV{MPEG2_ANDROID_NDK_PATH}")
endif()

if(NOT MPEG2_ANDROID_NDK_PATH)
  message(FATAL_ERROR "MPEG2_ANDROID_NDK_PATH not set.")
  return()
endif()

include("${MPEG2_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake")