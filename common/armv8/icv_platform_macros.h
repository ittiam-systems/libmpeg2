/******************************************************************************
 *
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *****************************************************************************
 * Originally developed and contributed by Ittiam Systems Pvt. Ltd, Bangalore
*/
/**
*******************************************************************************
* @file
*  icv_platform_macros.h
*
* @brief
*  This header files contains all the platform/toolchain specific macros
*
* @author
*  Ittiam
*
* @par List of Functions:
*
* @remarks
*  None
*
*******************************************************************************
*/
#ifndef __ICV_PLATFORM_MACROS_H__
#define __ICV_PLATFORM_MACROS_H__

static __inline UWORD32 CLZ(UWORD32 u4_word)
{
    if(u4_word)
        return (__builtin_clz(u4_word));
    else
        return 32;
}

static __inline  UWORD32 CLZNZ(UWORD32 u4_word)
{
    ASSERT(u4_word);
    return (__builtin_clz(u4_word));
}

#define CLIP_U8(x) ((x) > 255) ? (255) : (((x) < 0) ? (0) : (x))
#define CLIP_S8(x) ((x) > 127) ? (127) : (((x) < -128) ? (-128) : (x))

#define CLIP_U12(x) ((x) > 4095) ? (4095) : (((x) < 0) ? (0) : (x))
#define CLIP_S12(x) ((x) > 2047) ? (2047) : (((x) < -2048) ? (-2048) : (x))

#define CLIP_U16(x) ((x) > 65535) ? (65535) : (((x) < 0) ? (0) : (x))
#define CLIP_S16(x) ((x) > 32767) ? (32767) : (((x) < -32768) ? (-32768) : (x))

#define ITT_BIG_ENDIAN(x) __asm__("rev %0, %1" : "=r"(x) : "r"(x));

#define NOP(nop_cnt)                                \
{                                                   \
    UWORD32 nop_i;                                  \
    for (nop_i = 0; nop_i < nop_cnt; nop_i++)       \
        __asm__ __volatile__("mov x0, x0");         \
}


#define PREFETCH(x) __builtin_prefetch(x);

#define DATA_SYNC() __sync_synchronize()

#define SHL(x,y) (((y) < 32) ? ((x) << (y)) : 0)
#define SHR(x,y) (((y) < 32) ? ((x) >> (y)) : 0)

#define SHR_NEG(val,shift)  (((shift) > 0) ? ( (val) >> (shift)) : ((val) << (-(shift))))
#define SHL_NEG(val,shift)  (((shift) > 0) ? ( (val) >> (-(shift))) : ((val) << (shift)))

#define MEM_ALIGN8 __attribute__ ((aligned (8)))
#define MEM_ALIGN16 __attribute__ ((aligned (16)))
#define MEM_ALIGN32 __attribute__ ((aligned (32)))


#endif /* __ICV_PLATFORM_MACROS_H__ */
